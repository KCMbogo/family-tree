import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../domain/services/tree_layout.dart';
import '../../../providers/tree_providers.dart';
import '../../widgets/async_view.dart';
import '../../widgets/person_card.dart';
import 'tree_connector_painter.dart';

/// Feature §6.4 — the tree itself.
///
/// A genealogical chart: generations run top to bottom, couples sit side by
/// side joined by a marriage bar, and children hang from the couple's midpoint
/// under a shared sibling bar. The whole chart is framed to fit on open, then
/// pans and zooms.
class TreeViewScreen extends ConsumerWidget {
  const TreeViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(primaryTreeProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(tree?.name ?? 'Family tree'),
        actions: [
          IconButton(
            tooltip: 'People',
            icon: const Icon(Icons.list_alt_outlined),
            onPressed: () => _showPeopleList(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.addPerson),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Add person'),
      ),
      body: AsyncView(
        value: ref.watch(treeLayoutProvider),
        builder: (context, layout) => layout.isEmpty
            ? EmptyState(
                icon: Icons.park_outlined,
                title: 'Your tree is empty',
                message: 'Add the first family member — usually yourself, or '
                    'the oldest relative you know of.',
                action: FilledButton.icon(
                  onPressed: () => context.push(Routes.addPerson),
                  icon: const Icon(Icons.person_add_alt),
                  label: const Text('Add the first person'),
                ),
              )
            : Stack(
                children: [
                  Positioned.fill(child: _TreeCanvas(layout: layout)),
                  if (_needsConnecting(layout))
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: _ConnectPrompt(layout: layout),
                    ),
                ],
              ),
      ),
    );
  }

  /// True when people exist but none are linked — the state that makes the
  /// screen look like a list instead of a tree.
  static bool _needsConnecting(TreeLayout layout) =>
      layout.nodes.length >= 2 && layout.edges.isEmpty;

  void _showPeopleList(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (context, controller) => Consumer(
          builder: (context, ref, _) => AsyncView(
            value: ref.watch(personsProvider),
            builder: (context, people) => ListView.builder(
              controller: controller,
              itemCount: people.length,
              itemBuilder: (context, index) => PersonListTile(
                person: people[index],
                onTap: () {
                  Navigator.pop(context);
                  context.push(Routes.person(people[index].id));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nudges the user toward the one action that turns a pile of people into a
/// family tree. Without it, relationships are buried inside each profile.
class _ConnectPrompt extends StatelessWidget {
  const _ConnectPrompt({required this.layout});

  final TreeLayout layout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            Icon(Icons.hub_outlined, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Nobody is connected yet. Add a parent, marriage or sibling '
                'link to build the tree.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSecondaryContainer),
              ),
            ),
            const SizedBox(width: 8),
            // The app theme gives FilledButton a full-width minimum, which
            // forces infinite width inside a Row — so size this one locally.
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              onPressed: () =>
                  context.push(Routes.addRelationship(layout.nodes.first.id)),
              child: const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TreeCanvas extends StatefulWidget {
  const _TreeCanvas({required this.layout});

  final TreeLayout layout;

  @override
  State<_TreeCanvas> createState() => _TreeCanvasState();
}

class _TreeCanvasState extends State<_TreeCanvas> {
  final _controller = TransformationController();
  bool _framed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Slot space (x in card pitches, generation row) to canvas pixels, at the
  /// centre of the card.
  Offset _toOffset(double x, int generation) => Offset(
        TreeMetrics.canvasPadding + x * TreeMetrics.columnPitch,
        TreeMetrics.canvasPadding +
            generation * TreeMetrics.rowPitch +
            TreeMetrics.cardHeight / 2,
      );

  Size get _canvasSize => Size(
        widget.layout.width * TreeMetrics.columnPitch +
            TreeMetrics.canvasPadding * 2,
        widget.layout.generationCount * TreeMetrics.rowPitch -
            TreeMetrics.rowGap +
            TreeMetrics.canvasPadding * 2,
      );

  /// Scales and centres the whole chart on first build, so a wide tree opens
  /// readable instead of scrolled off to one side.
  void _frame(Size viewport) {
    final canvas = _canvasSize;
    if (canvas.width <= 0 || canvas.height <= 0) return;

    final scale = (viewport.width / canvas.width)
        .clamp(0.0, viewport.height / canvas.height)
        .clamp(0.35, 1.0);

    final dx = (viewport.width - canvas.width * scale) / 2;
    final dy = (viewport.height - canvas.height * scale) / 2;

    _controller.value = Matrix4.identity()
      ..translateByDouble(dx, dy < 0 ? 0 : dy, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canvas = _canvasSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_framed) {
          _framed = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _frame(constraints.biggest);
          });
        }

        return InteractiveViewer(
          transformationController: _controller,
          constrained: false,
          minScale: 0.2,
          maxScale: 2.5,
          boundaryMargin: const EdgeInsets.all(400),
          child: SizedBox(
            width: canvas.width,
            height: canvas.height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: TreeConnectorPainter(
                      layout: widget.layout,
                      toOffset: _toOffset,
                      cardSize: const Size(
                        TreeMetrics.cardWidth,
                        TreeMetrics.cardHeight,
                      ),
                      lineColor: scheme.outline,
                      coupleColor: scheme.primary,
                    ),
                  ),
                ),
                for (final node in widget.layout.nodes)
                  Positioned(
                    left: _toOffset(node.x, node.generation).dx -
                        TreeMetrics.cardWidth / 2,
                    top: _toOffset(node.x, node.generation).dy -
                        TreeMetrics.cardHeight / 2,
                    child: PersonCard(
                      person: node.person,
                      width: TreeMetrics.cardWidth,
                      height: TreeMetrics.cardHeight,
                      onTap: () => context.push(Routes.person(node.id)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
