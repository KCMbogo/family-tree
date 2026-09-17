import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../domain/models/tree_style.dart';
import '../../../domain/services/tree_layout.dart';
import '../../../providers/tree_providers.dart';
import '../../../providers/tree_style_provider.dart';
import '../../widgets/async_view.dart';
import '../../widgets/person_card.dart';
import '../../widgets/portrait_card.dart';
import 'organic_tree_painter.dart';
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
    final style = ref.watch(treeStyleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tree?.name ?? 'Family tree'),
        actions: [
          IconButton(
            tooltip: 'Tree style',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => _showStylePicker(context, ref, style),
          ),
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
                  Positioned.fill(
                    child: _TreeCanvas(layout: layout, style: style),
                  ),
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

  void _showStylePicker(
    BuildContext context,
    WidgetRef ref,
    TreeStyle current,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        // Scrollable: three descriptions plus the drag handle can exceed the
        // sheet's share of a short screen, and a fixed Column would clip.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'Tree style',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              RadioGroup<TreeStyle>(
                groupValue: current,
                onChanged: (chosen) {
                  Navigator.pop(sheetContext);
                  if (chosen != null) {
                    ref.read(treeStyleProvider.notifier).select(chosen);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final style in TreeStyle.values)
                      RadioListTile<TreeStyle>(
                        value: style,
                        title: Text(style.label),
                        subtitle: Text(style.description),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

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
  const _TreeCanvas({required this.layout, required this.style});

  final TreeLayout layout;
  final TreeStyle style;

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

  TreeMetrics get _metrics => switch (widget.style) {
        TreeStyle.chart => TreeMetrics.chart,
        TreeStyle.organic => TreeMetrics.organic,
        TreeStyle.portrait => TreeMetrics.portrait,
      };

  @override
  void didUpdateWidget(_TreeCanvas old) {
    super.didUpdateWidget(old);
    // Switching style changes the canvas size, so re-frame it rather than
    // leaving the view scrolled to a position that no longer means anything.
    if (old.style != widget.style) _framed = false;
  }

  /// Slot space (x in card pitches, generation row) to canvas pixels, at the
  /// centre of the card.
  Offset _toOffset(double x, int generation) {
    final m = _metrics;
    return Offset(
      m.canvasPadding + x * m.columnPitch,
      m.canvasPadding + generation * m.rowPitch + m.cardHeight / 2,
    );
  }

  Size get _canvasSize {
    final m = _metrics;
    return Size(
      widget.layout.width * m.columnPitch + m.canvasPadding * 2,
      widget.layout.generationCount * m.rowPitch -
          m.rowGap +
          m.canvasPadding * 2,
    );
  }

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

  CustomPainter _painterFor(ColorScheme scheme) => switch (widget.style) {
        TreeStyle.organic => OrganicTreePainter(
            layout: widget.layout,
            toOffset: _toOffset,
            cardSize: _metrics.cardSize,
            branchColor: scheme.primary.withValues(alpha: 0.55),
            coupleColor: scheme.tertiary,
          ),
        TreeStyle.chart || TreeStyle.portrait => TreeConnectorPainter(
            layout: widget.layout,
            toOffset: _toOffset,
            cardSize: _metrics.cardSize,
            lineColor: scheme.outline,
            coupleColor: scheme.primary,
          ),
      };

  Widget _cardFor(TreeNode node) {
    final m = _metrics;
    void open() => context.push(Routes.person(node.id));

    return switch (widget.style) {
      TreeStyle.portrait => PortraitCard(
          person: node.person,
          width: m.cardWidth,
          height: m.cardHeight,
          onTap: open,
        ),
      TreeStyle.chart || TreeStyle.organic => PersonCard(
          person: node.person,
          width: m.cardWidth,
          height: m.cardHeight,
          onTap: open,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canvas = _canvasSize;
    final m = _metrics;

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
                  child: CustomPaint(painter: _painterFor(scheme)),
                ),
                for (final node in widget.layout.nodes)
                  Positioned(
                    left: _toOffset(node.x, node.generation).dx -
                        m.cardWidth / 2,
                    top: _toOffset(node.x, node.generation).dy -
                        m.cardHeight / 2,
                    child: _cardFor(node),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
