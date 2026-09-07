# Flutter UI Coding & Layout Safety Rules

To prevent common rendering and runtime exceptions (such as `RenderFlex overflowed by X pixels` and protected member violations), all new and refactored Flutter code must adhere to the following rules:

---

## 1. Prevent Horizontal `RenderFlex` Overflows (Row & Flex)

1. **Always Constrain Dynamic Text in a `Row`**:
   - Never put unconstrained `Text` widgets directly next to other widgets (`Icon`, `SizedBox`, `CircleAvatar`, buttons) in a `Row`.
   - Wrap dynamic text with `Flexible` or `Expanded`, and explicitly set `overflow: TextOverflow.ellipsis` and `maxLines: 1` (or desired line count).
   ```dart
   // BAD:
   Row(
     children: [
       Icon(Icons.label),
       const SizedBox(width: 8),
       Text(dynamicTitle), // Will overflow on narrow screens or long translations
     ],
   )

   // GOOD:
   Row(
     children: [
       Icon(Icons.label),
       const SizedBox(width: 8),
       Flexible(
         child: Text(
           dynamicTitle,
           maxLines: 1,
           overflow: TextOverflow.ellipsis,
         ),
       ),
     ],
   )
   ```

2. **AppBar Title Safety**:
   - Avoid hardcoding `centerTitle: true` on `AppBar`s that feature multiple action buttons in `actions: [...]` or custom `leading` widgets.
   - Flutter's `NavigationToolbar` centers titles by reserving `2 * max(leadingWidth, actionsWidth)`. On mobile viewports (320px–390px), 3 action icons (~144px) leave less than 100px for a centered title.
   - Always wrap custom title row text in `Flexible(child: Text(..., overflow: TextOverflow.ellipsis))` and prefer `centerTitle: false` (or allow caller configuration defaulting to `false`).

3. **Multi-Language String Expansion**:
   - Strings in localized languages (such as Nias or Indonesian) can be significantly longer than the default English source string.
   - Never assume fixed pixel widths for labels, chips, or segmented buttons. Always design layouts assuming strings can expand by 50%–100%.

---

## 2. Prevent Vertical `RenderFlex` Overflows (Column & Scrollability)

1. **Scrollable Containers for Modals, Sheets, and Forms**:
   - Any screen, dialog, or bottom sheet containing form fields, varying content heights, or instructions must be wrapped in `SingleChildScrollView` or `ListView`.
   - Ensure bottom sheets accommodate the on-screen soft keyboard using `padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)`.

2. **Bounded Height in Columns**:
   - Never place unconstrained `ListView` or `GridView` inside a `Column` without wrapping in `Expanded` or setting `shrinkWrap: true` with `physics: const NeverScrollableScrollPhysics()`.

---

## 3. Safe State Management & Controller Usage

1. **Do Not Call Protected Members Externally**:
   - Never invoke `@protected` or `@visibleForTesting` methods like `notifyListeners()` on a `ChangeNotifier` from outside the controller subclass.
   - Expose explicit public methods on the controller (e.g., `void notifyStateChanged() => notifyListeners();` or dedicated domain methods like `resetState()`, `updateAnswer()`).

---

## 4. Responsive & Mobile Viewport Testing

1. **Verify on Narrow Screen Sizes in Widget Tests**:
   - When introducing or altering screens with headers, action rows, or card grids, test rendering at narrow screen widths (e.g. `320.0`, `360.0`, `390.0` pixels) to ensure no `RenderFlex` assertions occur.
   ```dart
   tester.view.physicalSize = const Size(320, 800);
   tester.view.devicePixelRatio = 1.0;
   // Pump widget and assert tester.takeException() is null
   ```
