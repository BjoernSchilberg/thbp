// Blockly-style blocks visualization for Typst v4
// Based on abbozza!Worlds SVG templates with exact geometry
// Features: 3D shadow effect, embedded icons, input fields, condition blocks

// ============================================================================
// CONSTANTS (from SVG analysis)
// ============================================================================

// Block dimensions (in pt, matching SVG pixel values)
#let corner-radius = 8pt
#let block-height = 26pt
#let block-min-height = 26pt
#let header-height = 25pt
#let footer-height = 10pt
#let inner-corner-radius = 8pt

// Puzzle connector geometry (trapezoid: l 6,4 3,0 6,-4)
#let tab-rise = 4pt
#let tab-slope = 6pt
#let tab-flat = 3pt
#let tab-total-width = 15pt  // 6 + 3 + 6

// Tab positions
#let tab-start-x = 15pt      // Start position of tab from left (H 15 l 6,4...)
#let bottom-tab-end-x = 29.5pt // Bottom tab ends here (H 29.5 l -6,4...)
#let inner-tab-end-x = 50pt  // Inner tab ends here for C-blocks (H 50 l -6,4...)

// Side connector for conditions (S-curve)
#let side-connector-height = 20pt

// Text and icon positioning
#let icon-x = 10pt
#let icon-y = 5pt
#let icon-size = 16pt
#let text-x = 36pt
#let text-y = 5pt
#let text-baseline = 5pt  // Reduced from 12.5pt to move text higher

// C-block inner indentation
#let c-block-indent = 21pt

// ============================================================================
// COLOR SCHEMES (from SVG analysis)
// ============================================================================

#let hathi-colors = (
  hathi: (
    primary: rgb("#00A000"),
    dark: rgb("#008000"),
    light: rgb("#4dbd4d"),
  ),
  kontrolle-falls: (
    primary: rgb("#FFA000"),
    dark: rgb("#cc8000"),
    light: rgb("#ffbd4d"),
  ),
  kontrolle-wiederhole: (
    primary: rgb("#FF8000"),
    dark: rgb("#cc6600"),
    light: rgb("#ffa64d"),
  ),
  hauptprogramm: (
    primary: rgb("#FF8000"),
    dark: rgb("#cc6600"),
    light: rgb("#ffa64d"),
  ),
  eingabe: (
    primary: rgb("#C0C0C0"),
    dark: rgb("#9a9a9a"),
    light: rgb("#d3d3d3"),
  ),
  variablen: (
    primary: rgb("#FF6000"),
    dark: rgb("#cc4d00"),
    light: rgb("#ff904d"),
  ),
  text: (
    primary: rgb("#0040FF"),
    dark: rgb("#0033cc"),
    light: rgb("#4d79ff"),
  ),
  zahlen: (
    primary: rgb("#800080"),
    dark: rgb("#660066"),
    light: rgb("#a64da6"),
  ),
  logik: (
    primary: rgb("#FF0000"),
    dark: rgb("#cc0000"),
    light: rgb("#ff4d4d"),
  ),
)

// ============================================================================
// EMBEDDED ICONS (loaded from external SVG files)
// ============================================================================

// Load icons from external SVG files
#let gear-icon = read("svg/gear-icon.svg")
#let hathi-icon = read("svg/hathi-icon.svg")
#let if-icon = read("svg/if-icon.svg")
#let loop-icon = read("svg/loop-icon.svg")

// ============================================================================
// PATH GENERATION FUNCTIONS
// ============================================================================

// Simple block path (statement block with tab/socket)
// Using cubic bezier for corners instead of arc
#let create-simple-block-path(width, height, has-top-socket: true, has-bottom-tab: true) = {
  let r = corner-radius
  let w = width
  let h = height
  // Control point factor for approximating quarter circle with cubic bezier
  let k = 0.552284749831  // 4/3 * tan(pi/8)
  
  (
    // Start at top-left, after corner
    curve.move((r, 0pt)),
    // Top edge to tab start
    curve.line((tab-start-x, 0pt)),
    // Top socket/tab (trapezoid pointing down into block)
    ..if has-top-socket {
      (
        curve.line((tab-slope, tab-rise), relative: true),
        curve.line((tab-flat, 0pt), relative: true),
        curve.line((tab-slope, -tab-rise), relative: true),
      )
    } else {
      ()
    },
    // Continue to top-right (no corner - straight edge)
    curve.line((w, 0pt)),
    // Right edge (straight down)
    curve.line((w, h)),
    // Bottom edge to tab start (H 29.5 from SVG)
    curve.line((bottom-tab-end-x, h)),
    // Bottom tab (trapezoid pointing down out of block: l -6,4 -3,0 -6,-4)
    ..if has-bottom-tab {
      (
        curve.line((-tab-slope, tab-rise), relative: true),
        curve.line((-tab-flat, 0pt), relative: true),
        curve.line((-tab-slope, -tab-rise), relative: true),
      )
    } else {
      ()
    },
    // Continue to bottom-left corner (h -7 then to corner)
    curve.line((r, h)),
    // Bottom-left corner
    curve.cubic((r - r*k, h), (0pt, h - r + r*k), (0pt, h - r)),
    // Left edge
    curve.line((0pt, r)),
    // Top-left corner
    curve.cubic((0pt, r - r*k), (r - r*k, 0pt), (r, 0pt)),
    // Close path
    curve.close(),
  )
}

// C-block path (control structure with inner cavity)
// side-connector-start: Y position where the S-curve starts (default 5pt, increase for taller conditions)
#let create-c-block-path(width, header-h, inner-h, has-top-socket: true, has-bottom-tab: true, has-side-connector: true, side-connector-start: 5pt) = {
  let r = corner-radius
  let ir = inner-corner-radius
  let w = width
  let total-h = header-h + inner-h + footer-height
  let k = 0.552284749831  // bezier control factor
  
  // Side connector S-curve is 20pt tall (from y=start to y=start+20)
  // The curve control points are relative to the start position
  let sc-start = side-connector-start
  let sc-end = sc-start + 20pt  // S-curve ends 20pt below start
  
  (
    // Start at top-left, after corner
    curve.move((r, 0pt)),
    // Top edge to tab
    curve.line((tab-start-x, 0pt)),
    // Top socket
    ..if has-top-socket {
      (
        curve.line((tab-slope, tab-rise), relative: true),
        curve.line((tab-flat, 0pt), relative: true),
        curve.line((tab-slope, -tab-rise), relative: true),
      )
    } else {
      ()
    },
    // Continue to top-right (no corner - straight edge)
    curve.line((w, 0pt)),
    // Right side down to side connector
    ..if has-side-connector {
      (
        // Go down to side connector start
        curve.line((w, sc-start)),
        // S-curve for side connector (20pt tall)
        // c 0,10 -8,-8 -8,7.5 - first cubic (relative: down 10, then bulge left)
        curve.cubic((w, sc-start + 10pt), (w - 8pt, sc-start - 8pt), (w - 8pt, sc-start + 7.5pt)),
        // s 8,-2.5 8,7.5 - smooth cubic (relative: continue S-curve)
        curve.cubic((w - 8pt, sc-start + 23pt), (w, sc-start + 5pt), (w, sc-start + 15pt)),
        // Go down to header-h
        curve.line((w, header-h)),
      )
    } else {
      (curve.line((w, header-h)),)
    },
    // Inner top edge (going left) - from SVG: H 50 l -6,4 -3,0 -6,-4
    curve.line((inner-tab-end-x, header-h)),
    // Inner tab (socket for nested blocks)
    curve.line((-tab-slope, tab-rise), relative: true),
    curve.line((-tab-flat, 0pt), relative: true),
    curve.line((-tab-slope, -tab-rise), relative: true),
    // Continue inner top to corner (h -7 a 8,8...)
    curve.line((c-block-indent + ir, header-h)),
    // Inner top-left corner (going down-left)
    curve.cubic((c-block-indent + ir - ir*k, header-h), (c-block-indent, header-h + ir - ir*k), (c-block-indent, header-h + ir)),
    // Inner left side
    curve.line((c-block-indent, header-h + inner-h - ir)),
    // Inner bottom-left corner (going right-down)
    curve.cubic((c-block-indent, header-h + inner-h - ir + ir*k), (c-block-indent + ir - ir*k, header-h + inner-h), (c-block-indent + ir, header-h + inner-h)),
    // Inner bottom edge (straight to right edge)
    curve.line((w, header-h + inner-h)),
    // Right side to bottom (straight down, no corner)
    curve.line((w, total-h)),
    // Bottom edge to tab (H 29.5 from SVG)
    curve.line((bottom-tab-end-x, total-h)),
    // Bottom tab
    ..if has-bottom-tab {
      (
        curve.line((-tab-slope, tab-rise), relative: true),
        curve.line((-tab-flat, 0pt), relative: true),
        curve.line((-tab-slope, -tab-rise), relative: true),
      )
    } else {
      ()
    },
    // Continue to bottom-left corner
    curve.line((r, total-h)),
    // Bottom-left corner
    curve.cubic((r - r*k, total-h), (0pt, total-h - r + r*k), (0pt, total-h - r)),
    // Left edge
    curve.line((0pt, r)),
    // Top-left corner
    curve.cubic((0pt, r - r*k), (r - r*k, 0pt), (r, 0pt)),
    // Close
    curve.close(),
  )
}

// Reporter/condition block path (with side puzzle connector)
#let create-reporter-block-path(width, height) = {
  let w = width
  let h = height
  
  (
    curve.move((0pt, 0pt)),
    curve.line((w, 0pt)),
    curve.line((w, h)),
    curve.line((0pt, h)),
    // V 20 - go to y=20 (which is h - 6pt for h=26)
    curve.line((0pt, h - 6pt)),
    // c 0,-10 -8,8 -8,-7.5 - cubic bezier (relative from 0, h-6 = 0, 20)
    // Control1: (0, 20-10) = (0, 10), Control2: (-8, 20+8) = (-8, 28), End: (-8, 20-7.5) = (-8, 12.5)
    curve.cubic((0pt, h - 16pt), (-8pt, h + 2pt), (-8pt, h - 13.5pt)),
    // s 8,2.5 8,-7.5 - smooth cubic (relative)
    // Previous endpoint: (-8, 12.5), Previous control2: (-8, 28)
    // Reflected control1: (-8, 12.5) + ((-8, 12.5) - (-8, 28)) = (-8, 12.5) + (0, -15.5) = (-8, -3)
    // Control2: (-8+8, 12.5+2.5) = (0, 15), End: (-8+8, 12.5-7.5) = (0, 5)
    curve.cubic((-8pt, -3pt), (0pt, h - 11pt), (0pt, 5pt)),
    curve.close(),
  )
}

// Hat block path (Hauptprogramm - no top socket)
#let create-hat-block-path(width, header-h, inner-h) = {
  let r = corner-radius
  let ir = inner-corner-radius
  let w = width
  let total-h = header-h + inner-h + footer-height
  let k = 0.552284749831  // bezier control factor
  
  (
    // Start at top-left, after corner
    curve.move((r, 0pt)),
    // Top edge (no socket) - directly to top-right (no corner on right side)
    curve.line((w, 0pt)),
    // Right side to inner (straight down)
    curve.line((w, header-h)),
    // Inner top edge - from SVG: H 50 l -6,4 -3,0 -6,-4
    curve.line((inner-tab-end-x, header-h)),
    // Inner tab
    curve.line((-tab-slope, tab-rise), relative: true),
    curve.line((-tab-flat, 0pt), relative: true),
    curve.line((-tab-slope, -tab-rise), relative: true),
    // Inner corner (h -7 a 8,8...)
    curve.line((c-block-indent + ir, header-h)),
    // Inner top-left corner (going down-left)
    curve.cubic((c-block-indent + ir - ir*k, header-h), (c-block-indent, header-h + ir - ir*k), (c-block-indent, header-h + ir)),
    // Inner left
    curve.line((c-block-indent, header-h + inner-h - ir)),
    // Inner bottom-left corner
    curve.cubic((c-block-indent, header-h + inner-h - ir + ir*k), (c-block-indent + ir - ir*k, header-h + inner-h), (c-block-indent + ir, header-h + inner-h)),
    // Inner bottom (straight to right edge)
    curve.line((w, header-h + inner-h)),
    // To bottom (straight down, no corner)
    curve.line((w, total-h)),
    // Bottom edge (no tab for hat blocks)
    curve.line((r, total-h)),
    // Bottom-left corner
    curve.cubic((r - r*k, total-h), (0pt, total-h - r + r*k), (0pt, total-h - r)),
    // Left edge
    curve.line((0pt, r)),
    // Top-left corner
    curve.cubic((0pt, r - r*k), (r - r*k, 0pt), (r, 0pt)),
    curve.close(),
  )
}

// If-Else block path (Falls-Sonst with TWO inner cavities)
// Based on SVG: header with side connector, first cavity, "Sonst" middle section, second cavity, footer
#let create-if-else-block-path(width, header-h, inner-h1, middle-h, inner-h2, side-connector-start: 5pt) = {
  let r = corner-radius
  let ir = inner-corner-radius
  let w = width
  let k = 0.552284749831  // bezier control factor
  
  // Side connector S-curve positioning
  let sc-start = side-connector-start
  
  // Y positions
  let y1 = header-h  // End of header / start of first cavity
  let y2 = header-h + inner-h1  // End of first cavity / start of middle
  let y3 = header-h + inner-h1 + middle-h  // End of middle / start of second cavity
  let y4 = header-h + inner-h1 + middle-h + inner-h2  // End of second cavity
  let total-h = y4 + footer-height
  
  (
    // Start at top-left, after corner
    curve.move((r, 0pt)),
    // Top edge to tab
    curve.line((tab-start-x, 0pt)),
    // Top socket
    curve.line((tab-slope, tab-rise), relative: true),
    curve.line((tab-flat, 0pt), relative: true),
    curve.line((tab-slope, -tab-rise), relative: true),
    // Continue to top-right
    curve.line((w, 0pt)),
    // Right side down to side connector (with adjustable start position)
    curve.line((w, sc-start)),
    curve.cubic((w, sc-start + 10pt), (w - 8pt, sc-start - 8pt), (w - 8pt, sc-start + 7.5pt)),
    curve.cubic((w - 8pt, sc-start + 23pt), (w, sc-start + 5pt), (w, sc-start + 15pt)),
    curve.line((w, y1)),
    
    // === First cavity (Falls/if-true) ===
    curve.line((inner-tab-end-x, y1)),
    curve.line((-tab-slope, tab-rise), relative: true),
    curve.line((-tab-flat, 0pt), relative: true),
    curve.line((-tab-slope, -tab-rise), relative: true),
    curve.line((c-block-indent + ir, y1)),
    curve.cubic((c-block-indent + ir - ir*k, y1), (c-block-indent, y1 + ir - ir*k), (c-block-indent, y1 + ir)),
    curve.line((c-block-indent, y2 - ir)),
    curve.cubic((c-block-indent, y2 - ir + ir*k), (c-block-indent + ir - ir*k, y2), (c-block-indent + ir, y2)),
    curve.line((w, y2)),
    
    // === Middle section (Sonst label area) ===
    curve.line((w, y3)),
    
    // === Second cavity (Sonst/else) ===
    curve.line((inner-tab-end-x, y3)),
    curve.line((-tab-slope, tab-rise), relative: true),
    curve.line((-tab-flat, 0pt), relative: true),
    curve.line((-tab-slope, -tab-rise), relative: true),
    curve.line((c-block-indent + ir, y3)),
    curve.cubic((c-block-indent + ir - ir*k, y3), (c-block-indent, y3 + ir - ir*k), (c-block-indent, y3 + ir)),
    curve.line((c-block-indent, y4 - ir)),
    curve.cubic((c-block-indent, y4 - ir + ir*k), (c-block-indent + ir - ir*k, y4), (c-block-indent + ir, y4)),
    curve.line((w, y4)),
    
    // === Footer ===
    curve.line((w, total-h)),
    curve.line((bottom-tab-end-x, total-h)),
    // Bottom tab
    curve.line((-tab-slope, tab-rise), relative: true),
    curve.line((-tab-flat, 0pt), relative: true),
    curve.line((-tab-slope, -tab-rise), relative: true),
    // Continue to bottom-left corner
    curve.line((r, total-h)),
    curve.cubic((r - r*k, total-h), (0pt, total-h - r + r*k), (0pt, total-h - r)),
    // Left edge
    curve.line((0pt, r)),
    // Top-left corner
    curve.cubic((0pt, r - r*k), (r - r*k, 0pt), (r, 0pt)),
    curve.close(),
  )
}

// ============================================================================
// RENDERING FUNCTIONS
// ============================================================================

// Render icon from SVG string
#let render-icon(icon-svg, x: icon-x, y: icon-y, size: icon-size) = {
  place(
    top + left,
    dx: x,
    dy: y,
    image(bytes(icon-svg), width: size, height: size)
  )
}

// Render block text
#let render-text(content, x: text-x, y: text-y) = {
  place(
    top + left,
    dx: x,
    dy: y + text-baseline,
    text(fill: white, font: "Liberation Sans", size: 11pt, weight: 500, content)
  )
}

// Render input field (rounded rect with value)
#let render-input-field(value, x, y, width: auto, dropdown: false, color: hathi-colors.hathi.primary, empty-width: 60pt) = {
  context {
    let field-width = if width == auto { 
      if value == "" {
        empty-width
      } else {
        measure(text(size: 11pt, value)).width + 15pt
      }
    } else { 
      width 
    }
    let field-height = 16pt
    
    place(
      top + left,
      dx: x - 5pt,
      dy: y,
      box(
        width: field-width,
        height: field-height,
        radius: 4pt,
        fill: if value == "" { white } else { white.transparentize(40%) },
      )[
        #place(horizon + left, dx: 5pt)[
          #text(fill: black, size: 11pt, value)
          #if dropdown {
            text(fill: color, size: 11pt, [ ▾])
          }
        ]
      ]
    )
  }
}

// Main block rendering with 3D effect
#let render-block-3d(
  path-func,
  colors,
  width,
  height,
  content-func: none,
  stroke-width: 1pt,  // Added stroke for better visibility
) = {
  box(width: width + 2pt, height: height + 2pt)[
    // Layer 1: Dark shadow (offset 1,1)
    #place(top + left, dx: 1pt, dy: 1pt)[
      #curve(
        fill: colors.dark,
        ..path-func
      )
    ]
    // Layer 2: Main color with stroke for edge visibility
    #place(top + left)[
      #curve(
        fill: colors.primary,
        stroke: stroke(paint: colors.dark, thickness: stroke-width),
        ..path-func
      )
    ]
    // Layer 3: Light highlight (top and left edges only - as stroke)
    // Simplified: just use the main path with lighter stroke on top
    
    // Content (icons, text, etc.)
    #if content-func != none {
      content-func
    }
  ]
}

// ============================================================================
// BLOCK HEIGHT CALCULATION
// ============================================================================

// Calculate height of nested content using context/measure
#let calculate-nested-height(nested) = {
  if nested == none {
    block-min-height
  } else if type(nested) == array {
    let total = 0pt
    for item in nested {
      // Each item contributes at least block-height
      total = total + block-height
    }
    if total < block-min-height { block-min-height } else { total }
  } else {
    // Single content item
    block-height
  }
}

// Measure actual content height (requires context)
#let measure-nested-height(nested) = {
  if nested == none {
    block-min-height
  } else {
    context {
      let stacked = stack(spacing: 0pt, ..nested)
      let size = measure(stacked)
      if size.height < block-min-height { block-min-height } else { size.height }
    }
  }
}

// ============================================================================
// PUBLIC API: BLOCK TYPES
// ============================================================================

// Simple statement block (e.g., "Gehe vor")
#let hathi-block(
  label,
  icon: none,
  colors: hathi-colors.hathi,
  width: auto,
  has-top-socket: true,
  has-bottom-tab: true,
) = {
  let h = block-height
  
  // Calculate width based on content if auto
  layout(size => {
    let label-text = text(font: "Liberation Sans", size: 11pt, weight: 500, label)
    let measured = measure(label-text)
    let icon-space = if icon != none { icon-size + 5pt } else { 0pt }
    let w = if width == auto {
      // Text width + icon + padding
      measured.width + icon-space + text-x - 10pt
    } else {
      width
    }
    
    let path = create-simple-block-path(w, h, has-top-socket: has-top-socket, has-bottom-tab: has-bottom-tab)
    
    render-block-3d(
      path,
      colors,
      w,
      h,
      content-func: {
        if icon != none {
          render-icon(icon)
        }
        render-text(label)
      }
    )
  })
}

// Reporter/condition block (e.g., "vorne frei")
#let reporter-block(
  label,
  icon: none,
  colors: hathi-colors.hathi,
  width: auto,
) = {
  let h = header-height  // Use header-height (25pt) to match C-block side connector
  
  // Calculate width based on content if auto
  layout(size => {
    let label-text = text(font: "Liberation Sans", size: 11pt, weight: 500, label)
    let measured = measure(label-text)
    let icon-space = if icon != none { icon-size + 5pt } else { 0pt }
    let w = if width == auto {
      // Text width + icon + padding
      measured.width + icon-space + text-x -10pt
    } else {
      width
    }
    
    let path = create-reporter-block-path(w, h)
    
    box(width: w + 10pt, height: h)[
      // Offset to make room for side connector
      #place(top + left, dx: 8pt)[
        #render-block-3d(
          path,
          colors,
          w,
          h,
          content-func: {
            if icon != none {
              render-icon(icon)
            }
            render-text(label)
          }
        )
      ]
    ]
  })
}

// C-block (control structure with nested blocks)
#let c-block(
  label,
  nested: none,
  condition: none,
  icon: none,
  colors: hathi-colors.kontrolle-falls,
  width: 80pt,
  inner-height: auto,  // Can be set explicitly or calculated
  has-top-socket: true,
  has-bottom-tab: true,
  has-side-connector: true,
) = {
  // Pre-render nested content to measure it
  let nested-content = if nested != none {
    stack(spacing: 0pt, ..nested)
  } else {
    none
  }
  
  layout(size => {
    // Measure the nested content
    let inner-h = if inner-height != auto {
      inner-height
    } else if nested-content == none {
      block-min-height
    } else {
      let m = measure(nested-content)
      if m.height < block-min-height { block-min-height } else { m.height }
    }
    
    // Measure condition block height to adjust header if needed
    let cond-h = if condition != none {
      let m = measure(condition)
      m.height
    } else {
      0pt
    }
    
    // Standard side-connector S-curve is 20pt tall, starting at 5pt
    // If condition is taller, we need to extend the header to match exactly
    let standard-connector-height = 25pt  // 5pt start + 20pt curve
    let actual-header-h = if cond-h > standard-connector-height {
      cond-h  // Match header exactly to condition height
    } else {
      header-height
    }
    
    // Calculate where side connector S-curve should start
    // Center the 20pt S-curve in the header, or start at 5pt if header is standard
    let sc-start = if cond-h > standard-connector-height {
      (actual-header-h - 20pt) / 2  // Center the 20pt curve
    } else {
      5pt
    }
    
    let w = width
    let total-h = actual-header-h + inner-h + footer-height
    
    let path = create-c-block-path(w, actual-header-h, inner-h, 
      has-top-socket: has-top-socket, 
      has-bottom-tab: has-bottom-tab,
      has-side-connector: has-side-connector,
      side-connector-start: sc-start)
    
    box(width: w + 2pt, height: total-h + 2pt)[
      // Dark shadow
      #place(top + left, dx: 1pt, dy: 1pt)[
        #curve(fill: colors.dark, ..path)
      ]
      // Main with stroke for edge visibility
      #place(top + left)[
        #curve(fill: colors.primary, stroke: stroke(paint: colors.dark, thickness: 1pt), ..path)
      ]
      // Icon and text
      #if icon != none {
        render-icon(icon)
      }
      #render-text(label)
      
      // Render condition block in side connector
      #if condition != none {
        // Center condition vertically in the header area
        let cond-dy = if cond-h > 25pt {
          (actual-header-h - cond-h) / 2
        } else {
          0pt
        }
        place(
          top + left,
          dx: w - 8pt,  // Reporter box has 8pt internal offset, so place box 8pt left of block edge
          dy: cond-dy,  // Center vertically if header is taller
          condition
        )
      }
      
      // Render nested blocks
      #if nested-content != none {
        place(
          top + left,
          dx: c-block-indent,
          dy: actual-header-h + 1pt,
          nested-content
        )
      }
    ]
  })
}

// Hat block (Hauptprogramm - no top socket)
#let hat-block(
  label,
  nested: none,
  icon: none,
  colors: hathi-colors.hauptprogramm,
  width: 160pt,
  inner-height: auto,  // Can be set explicitly or calculated
) = {
  // Pre-render nested content to measure it
  let nested-content = if nested != none {
    stack(spacing: 0pt, ..nested)
  } else {
    none
  }
  
  layout(size => {
    // Measure the nested content
    let inner-h = if inner-height != auto {
      inner-height
    } else if nested-content == none {
      block-min-height
    } else {
      let m = measure(nested-content)
      if m.height < block-min-height { block-min-height } else { m.height }
    }
    
    let w = width
    let total-h = header-height + inner-h + footer-height
    
    let path = create-hat-block-path(w, header-height, inner-h)
    
    box(width: w + 2pt, height: total-h + 2pt)[
      // Dark shadow
      #place(top + left, dx: 1pt, dy: 1pt)[
        #curve(fill: colors.dark, ..path)
      ]
      // Main with stroke for edge visibility
      #place(top + left)[
        #curve(fill: colors.primary, stroke: stroke(paint: colors.dark, thickness: 1pt), ..path)
      ]
      // Icon
      #if icon != none {
        render-icon(icon)
      }
      #render-text(label)
      
      // Nested blocks
      #if nested-content != none {
        place(
          top + left,
          dx: c-block-indent,
          dy: header-height + 1pt,
          nested-content
        )
      }
    ]
  })
}

// ============================================================================
// CONVENIENCE WRAPPERS
// ============================================================================

// Hathi blocks
#let gehe-vor() = hathi-block("Gehe vor", icon: hathi-icon)
#let hisse-flagge() = hathi-block("Hisse Flagge", icon: hathi-icon)
#let hebe-bananen-auf() = hathi-block("Hebe Bananen auf", icon: hathi-icon)
#let hebe-tomaten-auf() = hathi-block("Hebe Tomaten auf", icon: hathi-icon)
#let lege-bananen-ab() = hathi-block("Lege Bananen ab", icon: hathi-icon)

// Gehe n-mal vor block with embedded number input
// Based on SVG: "Gehe [n] mal vor" with purple number block
#let gehe-n-mal(n: "4") = {
  let w = 165pt
  let h = 36pt  // Taller block to accommodate embedded input (from SVG: v 36)
  let colors = hathi-colors.hathi
  let input-colors = hathi-colors.zahlen  // Purple for numbers
  
  // Input block dimensions (from SVG)
  let input-x = 75pt   // Position of input block (from SVG: translate(88.87,6))
  let input-w = 28pt   // Width of input block (from SVG: H 28.15)
  let input-h = 25pt   // Height of input block (from SVG: v 25)
  let input-y = 6pt    // Y offset of input block
  
  let path = create-simple-block-path(w, h, has-top-socket: true, has-bottom-tab: true)
  
  render-block-3d(
    path,
    colors,
    w,
    h,
    content-func: {
      // Icon at y=10 (from SVG: transform="translate(10,10)")
      render-icon(hathi-icon, y: 10pt)
      // "Gehe" text (from SVG: transform="translate(36,10)")
      place(
        top + left,
        dx: text-x,
        dy: 10pt + text-baseline,
        text(fill: white, font: "Liberation Sans", size: 11pt, weight: 500, "Gehe")
      )
      // Embedded purple input block for number
      place(
        top + left,
        dx: input-x,
        dy: input-y,
      )[
        #box(width: input-w + 2pt, height: input-h + 2pt)[
          // Dark shadow for input block (offset 1,1)
          #place(top + left, dx: 1pt, dy: 1pt)[
            #rect(width: input-w, height: input-h, fill: input-colors.dark)
          ]
          // Dark shadow for side connector (offset 1,1)
          #place(top + left, dx: 1pt, dy: 6pt)[
            #curve(
              fill: input-colors.dark,
              curve.move((0pt, 0pt)),
              curve.cubic((-8pt, 0pt), (-8pt, 15pt), (0pt, 15pt)),
              curve.close(),
            )
          ]
          // Main input block
          #place(top + left)[
            #rect(width: input-w, height: input-h, fill: input-colors.primary)
          ]
          // Side connector (puzzle piece pointing left)
          #place(top + left, dx: 0pt, dy: 5pt)[
            #curve(
              fill: input-colors.primary,
              curve.move((0pt, 0pt)),
              curve.cubic((-8pt, 0pt), (-8pt, 15pt), (0pt, 15pt)),
              curve.close(),
            )
          ]
          // Number value in white box (from SVG: transform="translate(10,5)")
          #place(top + left, dx: 5pt, dy: 5pt)[
            #box(
              width: input-w - 10pt,
              height: 16pt,
              radius: 4pt,
              fill: if n == "" { white } else { white.transparentize(40%) },
            )[
              #place(horizon + center)[
                #text(fill: black, size: 11pt, strong[#n])
              ]
            ]
          ]
        ]
      ]
      // "mal vor" text (from SVG: transform="translate(128.02,10)")
      place(
        top + left,
        dx: 115pt,
        dy: 10pt + text-baseline,
        text(fill: white, font: "Liberation Sans", size: 11pt, weight: 500, "mal vor")
      )
    }
  )
}

// Gehe <Variable> mal vor block with embedded variable dropdown
// Based on SVG: "Gehe [Variable] mal vor" with orange variable block
// SVG path: M 175.890625,5 h -88.03125 v 5 c -8,0 -8,15 0,15 v 7 h 88.03125 z
#let gehe-variable-mal(variable: "Baeume") = {
  let w = 220pt
  let h = 36pt  // Taller block to accommodate embedded input
  let colors = hathi-colors.hathi
  let input-colors = hathi-colors.variablen  // Orange for variables
  
  // Variable block dimensions (from SVG)
  let input-x = 75pt   // Position of variable block
  let input-w = 88pt   // Width of variable block (from SVG: h -88.03125)
  let input-h = 25pt   // Height of variable block
  let input-y = 6pt    // Y offset of variable block
  
  let path = create-simple-block-path(w, h, has-top-socket: true, has-bottom-tab: true)
  
  render-block-3d(
    path,
    colors,
    w,
    h,
    content-func: {
      // Icon at y=10 (from SVG: transform="translate(10,10)")
      render-icon(hathi-icon, y: 10pt)
      // "Gehe" text (from SVG: transform="translate(36,10)")
      place(
        top + left,
        dx: text-x,
        dy: 10pt + text-baseline,
        text(fill: white, font: "Liberation Sans", size: 11pt, weight: 500, "Gehe")
      )
      // Embedded orange variable block with single S-curve
      place(
        top + left,
        dx: input-x,
        dy: input-y,
      )[
        #box(width: input-w + 2pt, height: input-h + 2pt)[
          // Dark shadow for variable block (offset 1,1)
          #place(top + left, dx: 1pt, dy: 1pt)[
            #rect(width: input-w, height: input-h, fill: input-colors.dark)
          ]
          // Dark shadow for side connector (offset 1,1)
          #place(top + left, dx: 1pt, dy: 6pt)[
            #curve(
              fill: input-colors.dark,
              curve.move((0pt, 0pt)),
              curve.cubic((-8pt, 0pt), (-8pt, 15pt), (0pt, 15pt)),
              curve.close(),
            )
          ]
          // Main variable block
          #place(top + left)[
            #rect(width: input-w, height: input-h, fill: input-colors.primary)
          ]
          // Side connector (single S-curve pointing left)
          #place(top + left, dx: 0pt, dy: 5pt)[
            #curve(
              fill: input-colors.primary,
              curve.move((0pt, 0pt)),
              curve.cubic((-8pt, 0pt), (-8pt, 15pt), (0pt, 15pt)),
              curve.close(),
            )
          ]
          // Variable name in white box with dropdown arrow
          #place(top + left, dx: 5pt, dy: 5pt)[
            #box(
              width: input-w - 10pt,
              height: 16pt,
              radius: 4pt,
              fill: white.transparentize(40%),
            )[
              #place(horizon + left, dx: 5pt)[
                #text(fill: black, size: 11pt, variable)
              ]
              #place(horizon + right, dx: -5pt)[
                #text(fill: input-colors.primary, size: 11pt, " ▾")
              ]
            ]
          ]
        ]
      ]
      // "mal vor" text (from SVG: transform="translate(185.890625,10)")
      place(
        top + left,
        dx: 172pt,
        dy: 10pt + text-baseline,
        text(fill: white, font: "Liberation Sans", size: 11pt, weight: 500, "mal vor")
      )
    }
  )
}

// Drehe block with dropdown field for direction
#let drehe(richtung: "links") = {
  // Calculate width based on whether richtung is empty
  let base-width = 128pt + 15pt  // Text width + padding
  let field-width = if richtung == "" { 60pt } else { 47pt }  // Match empty-width or typical "links"/"rechts" width
  let w = base-width + field-width
  let h = block-height
  let colors = hathi-colors.hathi
  
  let path = create-simple-block-path(w, h, has-top-socket: true, has-bottom-tab: true)
  
  render-block-3d(
    path,
    colors,
    w,
    h,
    content-func: {
      render-icon(hathi-icon)
      render-text("Drehe dich nach")
      // Dropdown field for direction - positioned after "Drehe dich nach" text
      // From SVG: transform="translate(152.734375,5)" - approximately 153pt from left
      render-input-field(richtung, 128pt, icon-y, dropdown: true, color: colors.primary)
    }
  )
}

// Legacy wrappers (for backwards compatibility)
#let drehe-links() = drehe(richtung: "links")
#let drehe-rechts() = drehe(richtung: "rechts")
#let nimm-auf() = hathi-block("Nimm auf", icon: hathi-icon)
#let lege-ab() = hathi-block("Lege ab", icon: hathi-icon)
#let sage(text: "Hallo") = hathi-block("Sage \"" + text + "\"", icon: hathi-icon, width: 140pt)

// Setze <Name> auf <Wert> block (Variables block)
// Based on SVG: Orange block with double S-curve connector, dropdown for name, and purple number input
// SVG path: m 0,8 A 8,8 0 0,1 8,0 H 15 l 6,4 3,0 6,-4 H 40 H 239.671875 v 36 H 29.5 l -6,4 -3,0 -6,-4 H 8 a 8,8 0 0,1 -8,-8 z
// Double S-curve for variable reporter: v 5 c -3.75,0 -3.75,7.5 0,7.5 c -3.75,0 -3.75,7.5 0,7.5 v 7
#let setze-auf(name: "<Name>", wert: "0") = {
  let w = 220pt
  let h = 36pt  // Taller block for embedded inputs
  let colors = hathi-colors.variablen
  let input-colors = hathi-colors.zahlen  // Purple for number value
  
  // Input block dimensions
  let input-w = 28pt
  let input-h = 25pt
  let input-y = 6pt
  
  // Dropdown dimensions (for name)
  let dropdown-x = 54pt
  let dropdown-w = 90pt
  
  // Number input position
  let number-x = 180pt
  
  let path = create-simple-block-path(w, h, has-top-socket: true, has-bottom-tab: true)
  
  render-block-3d(
    path,
    colors,
    w,
    h,
    content-func: {
      // "Setze" text
      place(
        top + left,
        dx: 10pt,
        dy: 10pt + text-baseline,
        text(fill: white, font: "Liberation Sans", size: 11pt, weight: 500, "Setze")
      )
      
      // Dropdown for variable name (with double S-curve connector)
      place(
        top + left,
        dx: dropdown-x,
        dy: input-y,
      )[
        #box(width: dropdown-w + 2pt, height: input-h + 2pt)[
          // Dark shadow for dropdown block (offset 1,1)
          #place(top + left, dx: 1pt, dy: 1pt)[
            #rect(width: dropdown-w, height: input-h, fill: colors.dark)
          ]
          // Dark shadow for double S-curve connector (offset 1,1)
          #place(top + left, dx: 1pt, dy: 1pt)[
            #curve(
              fill: colors.dark,
              curve.move((0pt, 0pt)),
              curve.cubic((-3.75pt, 0pt), (-3.75pt, 7.5pt), (0pt, 7.5pt)),
              curve.cubic((-3.75pt, 7.5pt), (-3.75pt, 15pt), (0pt, 15pt)),
              curve.line((0pt, input-h)),
              curve.line((0pt, 0pt)),
              curve.close(),
            )
          ]
          // Main dropdown block
          #place(top + left)[
            #rect(width: dropdown-w, height: input-h, fill: colors.primary)
          ]
          // Double S-curve side connector (for variable reporter)
          #place(top + left, dx: 0pt, dy: 0pt)[
            #curve(
              fill: colors.primary,
              curve.move((0pt, 0pt)),
              curve.cubic((-3.75pt, 0pt), (-3.75pt, 7.5pt), (0pt, 7.5pt)),
              curve.cubic((-3.75pt, 7.5pt), (-3.75pt, 15pt), (0pt, 15pt)),
              curve.line((0pt, input-h)),
              curve.line((0pt, 0pt)),
              curve.close(),
            )
          ]
          // Dropdown content in white box
          #place(top + left, dx: 5pt, dy: 5pt)[
            #box(
              width: dropdown-w - 10pt,
              height: 16pt,
              radius: 4pt,
              fill: white.transparentize(40%),
            )[
              #place(horizon + left, dx: 5pt)[
                #text(fill: black, size: 11pt, name)
              ]
              #place(horizon + right, dx: -5pt)[
                #text(fill: colors.primary, size: 11pt, " ▾")
              ]
            ]
          ]
        ]
      ]
      
      // "auf" text
      place(
        top + left,
        dx: dropdown-x + dropdown-w + 10pt,
        dy: 10pt + text-baseline,
        text(fill: white, font: "Liberation Sans", size: 11pt, weight: 500, "auf")
      )
      
      // Purple number input block for value
      place(
        top + left,
        dx: number-x,
        dy: input-y,
      )[
        #box(width: input-w + 2pt, height: input-h + 2pt)[
          // Dark shadow for input block (offset 1,1)
          #place(top + left, dx: 1pt, dy: 1pt)[
            #rect(width: input-w, height: input-h, fill: input-colors.dark)
          ]
          // Dark shadow for side connector (offset 1,1)
          #place(top + left, dx: 1pt, dy: 6pt)[
            #curve(
              fill: input-colors.dark,
              curve.move((0pt, 0pt)),
              curve.cubic((-8pt, 0pt), (-8pt, 15pt), (0pt, 15pt)),
              curve.close(),
            )
          ]
          // Main input block
          #place(top + left)[
            #rect(width: input-w, height: input-h, fill: input-colors.primary)
          ]
          // Side connector (puzzle piece pointing left)
          #place(top + left, dx: 0pt, dy: 5pt)[
            #curve(
              fill: input-colors.primary,
              curve.move((0pt, 0pt)),
              curve.cubic((-8pt, 0pt), (-8pt, 15pt), (0pt, 15pt)),
              curve.close(),
            )
          ]
          // Number value in white box
          #place(top + left, dx: 5pt, dy: 5pt)[
            #box(
              width: input-w - 10pt,
              height: 16pt,
              radius: 4pt,
              fill: white.transparentize(40%),
            )[
              #place(horizon + center)[
                #text(fill: black, size: 11pt, strong[#wert])
              ]
            ]
          ]
        ]
      ]
    }
  )
}

// Erhöhe <Name> block (Variables block - simple statement)
// Based on SVG: Orange block with "Erhöhe" text and dropdown for variable name
// SVG path: m 0,8 A 8,8 0 0,1 8,0 H 15 l 6,4 3,0 6,-4 H 40 H 144.921875 v 25 H 29.5 l -6,4 -3,0 -6,-4 H 8 a 8,8 0 0,1 -8,-8 z
#let erhoehe(name: "<Name>") = {
  let w = 145pt
  let h = block-height
  let colors = hathi-colors.variablen
  
  let path = create-simple-block-path(w, h, has-top-socket: true, has-bottom-tab: true)
  
  render-block-3d(
    path,
    colors,
    w,
    h,
    content-func: {
      // "Erhöhe" text (from SVG: transform="translate(10,5)")
      place(
        top + left,
        dx: 10pt,
        dy: text-y + text-baseline,
        text(fill: white, font: "Liberation Sans", size: 11pt, weight: 500, "Erhöhe")
      )
      // Dropdown for variable name (from SVG: transform="translate(67.265625,5)")
      render-input-field(name, 57pt, icon-y, dropdown: true, color: colors.primary)
    }
  )
}

// Condition blocks
#let vorne-frei() = reporter-block("vorne frei", icon: hathi-icon)
#let hat-sich-bewegt() = reporter-block("hat sich bewegt", icon: hathi-icon)
#let die-kiste-ist-zu() = reporter-block("die Kiste ist zu", icon: hathi-icon)
#let die-flagge-ist-gehisst() = reporter-block("die Flagge ist gehisst", icon: hathi-icon)

// Logic block: "nicht" (negation) - red reporter with embedded condition slot
// Based on SVG: Red reporter block with inner cavity for condition
// SVG path: m 0,0 H 20 H 81.46875 v 35 H 0 V 20 c 0,-10 -8,8 -8,-7.5 s 8,2.5 8,-7.5 z
//           M 71.46875,5 h -14.5 v 5 c 0,10 -8,-8 -8,7.5 s 8,-2.5 8,7.5 v 6 h 14.5 z
#let nicht(condition: none) = {
  let colors = hathi-colors.logik
  let text-label = "nicht"
  
  layout(size => {
    // Measure condition block if present
    let cond-content = if condition != none { condition } else { none }
    let cond-measured = if condition != none {
      measure(cond-content)
    } else {
      (width: 20pt, height: 20pt)  // Default empty slot size
    }
    
    // Calculate dimensions
    let label-text = text(font: "Liberation Sans", size: 11pt, weight: 500, text-label)
    let label-measured = measure(label-text)
    
    // Inner slot dimensions - use tighter padding when condition is present
    let slot-padding = if condition != none { 2pt } else { 10pt }
    let slot-x-padding = if condition != none { 3pt } else { 10pt }
    let end-padding = if condition != none { 2pt } else { 6pt }
    
    let slot-width = cond-measured.width + slot-padding
    let slot-height = cond-measured.height + 4pt
    let slot-x = 10pt + label-measured.width + slot-x-padding  // After "nicht" text
    let slot-y = 5pt
    
    // Total width
    let w = slot-x + slot-width + end-padding
    
    // Height (from SVG: 37pt base, adjust for content)
    let actual-h = if slot-height + 10pt > 37pt { slot-height + 1pt } else { 32pt }
    
    // Outer path (reporter shape with side connector on left)
    let outer-path = (
      curve.move((0pt, 0pt)),
      curve.line((w, 0pt)),
      curve.line((w, actual-h)),
      curve.line((0pt, actual-h)),
      // Side connector (S-curve going up) - from SVG: V 20 c 0,-10 -8,8 -8,-7.5 s 8,2.5 8,-7.5
      curve.line((0pt, 20pt)),
      curve.cubic((0pt, 10pt), (-8pt, 28pt), (-8pt, 12.5pt)),
      curve.cubic((-8pt, -2.5pt), (0pt, 15pt), (0pt, 5pt)),
      curve.line((0pt, 0pt)),
      curve.close(mode: "straight"),
    )
    
    // Inner cutout path (clockwise = hole, with own side connector)
    // From SVG: M 71.46875,5 h -14.5 v 5 c 0,10 -8,-8 -8,7.5 s 8,-2.5 8,7.5 v 6 h 14.5 z
    let inner-path = (
      curve.move((slot-x + slot-width, slot-y)),
      curve.line((slot-x + slot-width, slot-y + slot-height)),
      curve.line((slot-x, slot-y + slot-height)),
      // Inner side connector going down
      curve.line((slot-x, slot-y + 20pt)),
      curve.cubic((slot-x, slot-y + 10pt), (slot-x - 8pt, slot-y + 28pt), (slot-x - 8pt, slot-y + 12.5pt)),
      curve.cubic((slot-x - 8pt, slot-y - 2.5pt), (slot-x, slot-y + 15pt), (slot-x, slot-y + 5pt)),
      curve.line((slot-x, slot-y)),
      curve.close(mode: "straight"),
    )
    
    box(width: w + 10pt, height: actual-h)[
      // Offset to make room for side connector
      #place(top + left, dx: 8pt)[
        // Layer 1: Dark shadow (offset 1,1)
        #place(top + left, dx: 1pt, dy: 1pt)[
          #curve(
            fill: colors.dark,
            ..outer-path,
          )
        ]
        // Layer 2: Main color with stroke
        #place(top + left)[
          #curve(
            fill: colors.primary,
            stroke: stroke(paint: colors.dark, thickness: 1pt),
            ..outer-path,
          )
        ]
        // Layer 3: White inner slot background - only show when no condition
        #if condition == none {
          place(top  + left,dx: 2pt, dy: -2pt)[
            #curve(
              fill: white,
              ..inner-path,
            )
          ]
        }
        // Content
        // "nicht" text
        #place(
          top + left,
          dx: 5pt,
          dy: 10pt,
          text(font: "Liberation Sans", size: 11pt, weight: 500, fill: white, text-label)
        )
        // Embedded condition
        #if condition != none {
          place(
            top + left,
            dx: slot-x -4pt,
            dy: slot-y -2pt,
            condition
          )
        }
      ]
    ]
  })
}

// Reporter block with dropdown field (e.g., "Steht vor Bananen")
// Based on SVG: reporter block with text + dropdown
#let steht-vor(objekt: "Bananen") = {
  let h = header-height
  let colors = hathi-colors.hathi
  
  layout(size => {
    // Measure "Steht vor" text
    let label-text = text(font: "Liberation Sans", size: 11pt, weight: 500, "Steht vor")
    let label-measured = measure(label-text)
    
    // Measure dropdown value
    let dropdown-text = text(font: "Liberation Sans", size: 11pt, weight: 500, objekt)
    let dropdown-measured = measure(dropdown-text)
    
    // Calculate total width
    let icon-space = icon-size + 5pt
    let dropdown-width = dropdown-measured.width + 25pt  // Extra space for dropdown arrow
    let w = text-x + label-measured.width + 10pt + dropdown-width - 10pt
    
    let path = create-reporter-block-path(w, h)
    
    box(width: w + 10pt, height: h)[
      // Offset to make room for side connector
      #place(top + left, dx: 8pt)[
        #render-block-3d(
          path,
          colors,
          w,
          h,
          content-func: {
            render-icon(hathi-icon)
            render-text("Steht vor")
            // Dropdown field for object - positioned after "Steht vor" text
            render-input-field(objekt, text-x + label-measured.width + 10pt, icon-y, dropdown: true, color: colors.primary)
          }
        )
      ]
    ]
  })
}

// Generic reporter block with label and dropdown
#let reporter-dropdown(label, value, icon: hathi-icon, colors: hathi-colors.hathi) = {
  let h = header-height
  
  layout(size => {
    // Measure label text
    let label-text = text(font: "Liberation Sans", size: 11pt, weight: 500, label)
    let label-measured = measure(label-text)
    
    // Measure dropdown value
    let dropdown-text = text(font: "Liberation Sans", size: 11pt, weight: 500, value)
    let dropdown-measured = measure(dropdown-text)
    
    // Calculate total width
    let icon-space = if icon != none { icon-size + 5pt } else { 0pt }
    let dropdown-width = dropdown-measured.width + 25pt
    let w = text-x + label-measured.width + 10pt + dropdown-width + 10pt
    
    let path = create-reporter-block-path(w, h)
    
    box(width: w + 10pt, height: h)[
      #place(top + left, dx: 8pt)[
        #render-block-3d(
          path,
          colors,
          w,
          h,
          content-func: {
            if icon != none {
              render-icon(icon)
            }
            render-text(label)
            render-input-field(value, text-x + label-measured.width + 10pt, icon-y, dropdown: true, color: colors.primary)
          }
        )
      ]
    ]
  })
}

// Control structures
#let falls(condition: none, nested: none, inner-height: auto) = {
  c-block(
    "Falls",
    nested: nested,
    condition: condition,
    icon: if-icon,
    colors: hathi-colors.kontrolle-falls,
    has-side-connector: true,
    inner-height: inner-height,
  )
}

#let falls-sonst(condition: none, nested-if: none, nested-else: none) = {
  // Pre-render nested content to measure it
  let nested-if-content = if nested-if != none {
    stack(spacing: 0pt, ..nested-if)
  } else {
    none
  }
  let nested-else-content = if nested-else != none {
    stack(spacing: 0pt, ..nested-else)
  } else {
    none
  }
  
  let colors = hathi-colors.kontrolle-falls
  let w = 150pt
  let middle-h = 25pt  // Height of "Sonst" middle section
  
  layout(size => {
    // Measure the nested content
    let inner-h1 = if nested-if-content == none {
      block-min-height
    } else {
      let m = measure(nested-if-content)
      if m.height < block-min-height { block-min-height } else { m.height }
    }
    
    let inner-h2 = if nested-else-content == none {
      block-min-height
    } else {
      let m = measure(nested-else-content)
      if m.height < block-min-height { block-min-height } else { m.height }
    }
    
    // Measure condition block height to adjust header if needed
    let cond-h = if condition != none {
      let m = measure(condition)
      m.height
    } else {
      0pt
    }
    
    // Standard side-connector S-curve is 20pt tall, starting at 5pt
    let standard-connector-height = 25pt
    let actual-header-h = if cond-h > standard-connector-height {
      cond-h
    } else {
      header-height
    }
    
    // Calculate where side connector S-curve should start
    let sc-start = if cond-h > standard-connector-height {
      (actual-header-h - 20pt) / 2
    } else {
      5pt
    }
    
    let total-h = actual-header-h + inner-h1 + middle-h + inner-h2 + footer-height
    
    let path = create-if-else-block-path(w, actual-header-h, inner-h1, middle-h, inner-h2, side-connector-start: sc-start)
    
    box(width: w + 2pt, height: total-h + 2pt)[
      // Dark shadow
      #place(top + left, dx: 1pt, dy: 1pt)[
        #curve(fill: colors.dark, ..path)
      ]
      // Main with stroke for edge visibility
      #place(top + left)[
        #curve(fill: colors.primary, stroke: stroke(paint: colors.dark, thickness: 1pt), ..path)
      ]
      // Icon
      #render-icon(if-icon)
      // "Falls" text
      #render-text("Falls")
      // "Sonst" text in middle section
      #place(
        top + left,
        dx: icon-x,
        dy: actual-header-h + inner-h1 + text-baseline,
        text(fill: white, font: "Liberation Sans", size: 11pt, weight: 500, "Sonst")
      )
      
      // Render condition block in side connector
      #if condition != none {
        // Center condition vertically in the header area
        let cond-dy = if cond-h > 25pt {
          (actual-header-h - cond-h) / 2
        } else {
          0pt
        }
        place(
          top + left,
          dx: w - 8pt,
          dy: cond-dy,
          condition
        )
      }
      
      // Render nested-if blocks (first cavity)
      #if nested-if-content != none {
        place(
          top + left,
          dx: c-block-indent,
          dy: actual-header-h + 1pt,
          nested-if-content
        )
      }
      
      // Render nested-else blocks (second cavity)
      #if nested-else-content != none {
        place(
          top + left,
          dx: c-block-indent,
          dy: actual-header-h + inner-h1 + middle-h + 1pt,
          nested-else-content
        )
      }
    ]
  })
}


// Wiederhole n-mal block with embedded purple number input
// Based on SVG: Orange C-block with purple number block embedded
// SVG dimensions: viewBox="0 0 205.8 76", header height=36
#let wiederhole-n-mal(n: "4", nested: none) = {
  let w = 180pt  // From SVG viewBox width
  let colors = hathi-colors.kontrolle-wiederhole  // Orange
  let input-colors = hathi-colors.zahlen  // Purple for numbers
  
  // Input block dimensions
  let input-x = 105pt   // Näher an "Wiederhole"
  let input-w = 28pt
  let input-h = 25pt
  let input-y = 2pt    // Mittiger
  
  // Pre-render nested content to measure it
  let nested-content = if nested != none {
    stack(spacing: 0pt, ..nested)
  } else {
    none
  }
  
  // Use layout to measure nested content height
  layout(size => {
    let inner-h = if nested-content == none {
      block-min-height
    } else {
      let m = measure(nested-content)
      if m.height < block-min-height { block-min-height } else { m.height }
    }
    
    // Header-Höhe für diesen Block: 30pt (von SVG), damit Zahlenblock passt
    let my-header-h = 30pt
    let total-h = my-header-h + inner-h + footer-height
    
    let path = create-c-block-path(w, my-header-h, inner-h, has-top-socket: true, has-bottom-tab: true, has-side-connector: false)
    
    render-block-3d(
      path,
      colors,
      w,
      total-h,
      content-func: {
        // Loop icon at (10,10) - from SVG
        render-icon(loop-icon, y: 6pt)
        
        // "Wiederhole" text at (36,10) - from SVG
        place(
          top + left,
          dx: text-x,
          dy: 5pt + text-baseline,
          text(fill: white, font: "Liberation Sans", size: 11pt, weight: 500, "Wiederhole")
        )
        
        // Embedded purple input block for number
        place(
          top + left,
          dx: input-x,
          dy: input-y,
        )[
          #box(width: input-w + 2pt, height: input-h + 2pt)[
            // Dark shadow for input block (offset 1,1)
            #place(top + left, dx: 1pt, dy: 1pt)[
              #rect(width: input-w, height: input-h, fill: input-colors.dark)
            ]
            // Dark shadow for side connector (offset 1,1)
            #place(top + left, dx: 1pt, dy: 6pt)[
              #curve(
                fill: input-colors.dark,
                curve.move((0pt, 0pt)),
                curve.cubic((-8pt, 0pt), (-8pt, 15pt), (0pt, 15pt)),
                curve.close(),
              )
            ]
            // Main input block
            #place(top + left)[
              #rect(width: input-w, height: input-h, fill: input-colors.primary)
            ]
            // Side connector (puzzle piece pointing left)
            #place(top + left, dx: 0pt, dy: 5pt)[
              #curve(
                fill: input-colors.primary,
                curve.move((0pt, 0pt)),
                curve.cubic((-8pt, 0pt), (-8pt, 15pt), (0pt, 15pt)),
                curve.close(),
              )
            ]
            // Number value in white box (from SVG: transform="translate(10,5)")
            #place(top + left, dx: 5pt, dy: 5pt)[
              #box(
                width: input-w - 10pt,
                height: 16pt,
                radius: 4pt,
                fill: if n == "" { white } else { white.transparentize(40%) },
              )[
                #place(horizon + center)[
                  #text(fill: black, size: 11pt, strong[#n])
                ]
              ]
            ]
          ]
        ]
        
        // "-mal" text - nach links verschoben wegen Zahlenblock
        place(
          top + left,
          dx: 140pt,
          dy: 5pt + text-baseline,
          text(fill: white, font: "Liberation Sans", size: 11pt, weight: 500, "-mal")
        )
        
        // Nested content inside the cavity
        if nested-content != none {
          place(
            top + left,
            dx: c-block-indent,
            dy: my-header-h,
            nested-content
          )
        }
      }
    )
  })
}

#let wiederhole-fortlaufend(nested: none) = {
  c-block(
    "Wiederhole fortlaufend",
    nested: nested,
    icon: loop-icon,
    colors: hathi-colors.kontrolle-wiederhole,
    has-side-connector: false,
    width: 160pt,
  )
}

// Wiederhole solange (kopfgesteuerte Schleife mit Bedingung)
// Based on SVG: Orange C-block with side connector for condition
// Similar to "falls" but with loop-icon and different text
#let wiederhole-solange(condition: none, nested: none) = {
  c-block(
    "Wiederhole solange",
    nested: nested,
    condition: condition,
    icon: loop-icon,
    colors: hathi-colors.kontrolle-wiederhole,
    has-side-connector: true,
    width: 150pt,
  )
}

// Main program
#let hauptprogramm(nested: none, inner-height: auto) = {
  hat-block(
    "Hauptprogramm",
    nested: nested,
    icon: gear-icon,
    colors: hathi-colors.hauptprogramm,
    inner-height: inner-height,
  )
}

// ============================================================================
// PROGRAM ASSEMBLY
// ============================================================================

// Assemble a complete program
#let blockly-program(..blocks) = {
  let block-list = blocks.pos()
  stack(spacing: 0pt, ..block-list)
}
