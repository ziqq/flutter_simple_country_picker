part of 'country_list_view.dart';

/// A single lazy list with a separate, layout-synchronous pinned header.
class _CountryGroupedList extends RenderObjectWidget {
  const _CountryGroupedList({
    required this.delegate,
    required this.headers,
    required this.headerHeight,
    required this.headerBuilder,
  });

  final SliverChildDelegate delegate;
  final List<int> headers;
  final double headerHeight;
  final IndexedWidgetBuilder headerBuilder;

  @override
  RenderObjectElement createElement() => _CountryGroupedListElement(this);

  @override
  _RenderCountryGroupedList createRenderObject(BuildContext context) =>
      _RenderCountryGroupedList(
        headers: headers,
        headerHeight: headerHeight,
        updateHeader: (context as _CountryGroupedListElement).buildHeader,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderCountryGroupedList renderObject,
  ) {
    renderObject
      ..headers = headers
      ..headerHeight = headerHeight;
  }
}

class _CountryGroupedListElement extends RenderObjectElement {
  _CountryGroupedListElement(_CountryGroupedList super.widget);

  Element? _list;
  Element? _header;
  int? _headerIndex;
  bool _headerDirty = true;

  @override
  _CountryGroupedList get widget => super.widget as _CountryGroupedList;

  @override
  _RenderCountryGroupedList get renderObject =>
      super.renderObject as _RenderCountryGroupedList;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _list = updateChild(
      _list,
      _CountrySectionList(delegate: widget.delegate),
      0,
    );
  }

  @override
  void update(_CountryGroupedList newWidget) {
    super.update(newWidget);
    _headerDirty = true;
    _list = updateChild(
      _list,
      _CountrySectionList(delegate: widget.delegate),
      0,
    );
    renderObject.markNeedsLayout();
  }

  void buildHeader(int? index) {
    if (!_headerDirty && _headerIndex == index) return;
    owner!.buildScope(this, () {
      _header = updateChild(
        _header,
        index == null ? null : widget.headerBuilder(this, index),
        1,
      );
    });
    _headerIndex = index;
    _headerDirty = false;
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_list != null) visitor(_list!);
    if (_header != null) visitor(_header!);
  }

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    if (slot == 0) {
      renderObject.list = child as _RenderCountrySectionList;
    } else {
      renderObject.header = child as RenderBox;
    }
  }

  // Both private children have fixed slots and no GlobalKey, so neither moves.
  // coverage:ignore-start
  @override
  void moveRenderObjectChild(
    RenderObject child,
    Object? oldSlot,
    Object? newSlot,
  ) {
    assert(oldSlot == newSlot, 'The list and pinned header have fixed slots.');
  }

  // coverage:ignore-end

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    if (slot == 0) {
      // The private list retains slot 0 for the element's entire lifetime.
      renderObject.list = null; // coverage:ignore-line
    } else {
      renderObject.header = null;
    }
  }
}

/// The pinned copy owns semantics while its in-flow counterpart is covered.
class _CountrySectionList extends SliverList {
  const _CountrySectionList({required super.delegate});

  @override
  _RenderCountrySectionList createRenderObject(BuildContext context) =>
      _RenderCountrySectionList(
        childManager: context as SliverMultiBoxAdaptorElement,
      );
}

class _RenderCountrySectionList extends RenderSliverList {
  _RenderCountrySectionList({required super.childManager});

  int? _excludedHeader;
  int? get excludedHeader => _excludedHeader;

  set excludedHeader(int? value) {
    if (_excludedHeader == value) return;
    _excludedHeader = value;
    markNeedsSemanticsUpdate();
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    super.visitChildrenForSemantics((child) {
      if (indexOf(child as RenderBox) != excludedHeader) visitor(child);
    });
  }
}

class _RenderCountryGroupedList extends RenderSliver with RenderSliverHelpers {
  _RenderCountryGroupedList({
    required List<int> headers,
    required double headerHeight,
    required this.updateHeader,
  }) : _headers = headers,
       _headerHeight = headerHeight;

  final ValueChanged<int?> updateHeader;
  List<int> _headers;
  List<int> get headers => _headers;

  set headers(List<int> value) {
    _headers = value;
    markNeedsLayout();
  }

  double _headerHeight;
  double get headerHeight => _headerHeight;

  set headerHeight(double value) {
    if (_headerHeight == value) return;
    // Switching style replaces the selected/nonselected subtree. Retained
    // render objects keep one height; preserve the RenderObjectWidget contract.
    // coverage:ignore-start
    _headerHeight = value;
    markNeedsLayout();
    // coverage:ignore-end
  }

  _RenderCountrySectionList? _list;
  _RenderCountrySectionList? get list => _list;

  set list(_RenderCountrySectionList? value) {
    if (_list != null) dropChild(_list!);
    _list = value;
    if (_list != null) adoptChild(_list!);
  }

  RenderBox? _header;
  RenderBox? get header => _header;

  set header(RenderBox? value) {
    if (_header != null) dropChild(_header!);
    _header = value;
    if (_header != null) adoptChild(_header!);
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData)
      child.parentData = SliverPhysicalParentData();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _list?.attach(owner);
    _header?.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    _list?.detach();
    _header?.detach();
  }

  @override
  void redepthChildren() {
    if (_list != null) redepthChild(_list!);
    if (_header != null) redepthChild(_header!);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (_list != null) visitor(_list!);
    if (_header != null) visitor(_header!);
  }

  @override
  void performLayout() {
    final list = this.list!;
    geometry = (list..layout(constraints, parentUsesSize: true)).geometry;
    if (geometry!.scrollOffsetCorrection != null) return;

    // The list keeps actual offsets for its viewport/cache children. No row
    // height estimates or post-frame scroll listeners are needed for pinning.
    int? active;
    var nextHeader = double.infinity;
    for (
      var child = list.firstChild;
      child != null;
      child = list.childAfter(child)
    ) {
      final index = list.indexOf(child);
      final offset = list.childScrollOffset(child)!;
      if (offset <= constraints.scrollOffset) {
        final header = headers[index];
        active =
            header < 0 ||
                (header == index && offset == constraints.scrollOffset)
            ? null
            : header;
      } else if (headers[index] == index) {
        nextHeader = offset - constraints.scrollOffset;
        break;
      }
    }
    if (geometry!.paintExtent == 0) active = null;
    invokeLayoutCallback<SliverConstraints>((_) => updateHeader(active));
    list.excludedHeader = active;
    final header = this.header;
    if (header != null) {
      header.layout(
        constraints.asBoxConstraints(
          minExtent: headerHeight,
          maxExtent: headerHeight,
        ),
        parentUsesSize: true,
      );
      geometry = geometry!.copyWith(maxScrollObstructionExtent: headerHeight);
      (header.parentData! as SliverPhysicalParentData).paintOffset = Offset(
        0,
        math.min(0, nextHeader - headerHeight),
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!geometry!.visible) return;
    context.paintChild(_list!, offset);
    if (header case final pinned?) {
      context.paintChild(
        pinned,
        offset + (pinned.parentData! as SliverPhysicalParentData).paintOffset,
      );
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    if (header case final pinned?) {
      if (hitTestBoxChild(
        BoxHitTestResult.wrap(result),
        pinned,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      ))
        return true;
    }
    return _list!.hitTest(
      result,
      mainAxisPosition: mainAxisPosition,
      crossAxisPosition: crossAxisPosition,
    );
  }

  @override
  double childMainAxisPosition(RenderObject child) => child == _header
      ? (child.parentData! as SliverPhysicalParentData).paintOffset.dy
      : 0;

  @override
  double childCrossAxisPosition(RenderObject child) => 0;

  @override
  double? childScrollOffset(RenderObject child) =>
      child == _header ? constraints.scrollOffset : 0;

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) =>
      (child.parentData! as SliverPhysicalParentData).applyPaintTransform(
        transform,
      );
}
