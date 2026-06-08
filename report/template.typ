#import "@preview/tablex:0.0.9": tablex, colspanx, rowspanx, hlinex, vlinex, cellx
#import "@preview/showybox:2.0.4": showybox

#let state-course = state("course", none)
#let state-author = state("author", none)
#let state-school-id = state("school_id", none)
#let state-date = state("date", none)
#let state-theme = state("theme", none)
#let state-block-theme = state("block_theme", none)

#let _underlined_cell(content, color: black) = {
  tablex(
    align: center + horizon,
    stroke: 0pt,
    inset: 0.75em,
    map-hlines: h => {
      if (h.y > 0) {
        (..h, stroke: 0.5pt + color)
      } else {
        h
      }
    },
    columns: 1fr,
    content,
  )
}

#let fakebold(content) = {
  set text(stroke: 0.02857em) // https://gist.github.com/csimide/09b3f41e838d5c9fc688cc28d613229f
  content
}

#let asset-zju-banner = image.decode(
  format: "svg",
  width: 100%,
  "<svg version=\"1.0\" fill=\"black\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" width=\"255.1px\" height=\"80px\" viewBox=\"0 0 255.1 80\" style=\"enable-background:new 0 0 255.1 80.4;\" xml:space=\"preserve\">"
    + "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" id=\"XMLID_380_\" d=\"M175.6,68.9c-2.4-0.5-1-1.3-1.4-3.3c-0.3-1.8-1.9-3.5-1.9-4.8c0.1-3.5,4.7-3.3,7.4-2.2"
    + "c0.5,0.2,1.1,0.9,1.6,1.7c1.3,1.8,2.7,4.5,0.8,6.5C180.4,68.4,177.6,69.3,175.6,68.9\" />"
    + "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" id=\"XMLID_379_\" d=\"M148.3,65.2c-0.1,0-0.2-0.1-0.2-0.1c0-0.3,0-0.5,0.1-0.8c0.7-0.3,7.3-4.5,7.3-4.7"
    + "c1.9-1.5,3.6-3.2,4.1-5.6c-4.7,1.5-9.1,4.9-14,5.3c-2.2-0.6-3.8-1.8-5.4-2.5c0-0.1,0-0.2,0-0.3c-2.6-1.7-2.8-3.8,0-4.8"
    + "c4.9,1.1,12.3-2.4,16.9-4.2c1-0.5,4-1.5,4.8-2.4c1.1-6.4,0.4-12.9,0.8-19.1c1.6-4.5,4.3-1.4,7.1,0.8c0.2,0.4,0.8,0.8,1.4,1.6"
    + "c0.1,0,0.2,0,0.3,0c1.2,1.9,1.5,2.7-0.3,4.4c-1.2,3-1.8,6.4-1.7,9.9c3.4-0.5,5.4-3.4,9.3-3.5c0.9,1.8,0.8,3.3-0.9,4.8"
    + "c-2.8,1.4-5.9,2.6-9.1,4c-0.7,3.3-2,7.2-4.3,9.9c-0.3,0.4-2,1.9-2.4,2.2c-2.1,1.2-3.9,2.7-6.2,3.3"
    + "C149.5,65.3,149.4,65,148.3,65.2\" />"
    + "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" id=\"XMLID_378_\" d=\"M88.1,76.2c-2.3-1.1-4.4-3.9-5.7-5.6c0.2-0.6,0.4-1.2,0.7-1.8C88.6,64.7,94,60.9,98.9,56"
    + "c1.5-2.3,3.5-4.7,5.1-7c0.1,0,0.2-0.1,0.3-0.1c0-0.1,0-0.2,0-0.2c1.4-1.1,2-1.4,3.2,0.4c0.1,1.5-2.6,3.1-3.4,4.5"
    + "c-1,2.7-2.2,5.4-3.6,8.1c-0.4,0.5-0.4,0.5-2.2,3.3c-1.5,1.1-3.4,4.1-4.2,5.9c-1.7,1-2.5,4-4.5,5.1C88.9,76.1,88.5,76.1,88.1,76.2"
    + "\" />"
    + "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" id=\"XMLID_377_\" d=\"M120.3,57.1c-3.4-0.1-4.3-2.3-6.2-4.3c-0.1-0.9,0.5-1.4,0.6-2c0.8-0.2,0.8-0.2,1.4-0.5"
    + "c1.4-0.2,1.9-0.1,3.4-0.2c1.9-0.4,6.9-3.9,8.6-2.4C128.3,51.7,123.9,55.9,120.3,57.1\" />"
    + "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" id=\"XMLID_376_\" d=\"M94.5,50.6c-1.3-1.1-1.5-6.3-1.6-8c1-2.9,3.9-3,6.3-1.1c1.9,2.5,3.3,3.6,1.2,6.6"
    + "C98.1,50.1,97,50.2,94.5,50.6\" />"
    + "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" id=\"XMLID_375_\" d=\"M119.4,48.1c-0.4-1.6,1.8-5,1.2-5.8c-0.8,0.1-1.6,0.4-2.5,0.5c-2-1-4.2-3.4-3.4-5.3"
    + "c1.5-1.7,0.9-1.3,3.3-1.4c2.2-1,4.4-2,6.7-2.9c3.8-0.7,5.5,1.4,5.7,5.1c-0.7,2.4-2.3,4.3-3.8,6.2c-2,1.1-3.8,2.3-5.6,3.5"
    + "C120.4,47.9,119.9,48,119.4,48.1\" />"
    + "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" id=\"XMLID_374_\" d=\"M98.7,37.4c-0.8-0.7-0.5-1.1,0-1.8c-0.1-1.6-1-2.8-1.1-4.3c0.5-2.7,0-3.7,2.3-5.1"
    + "c1.8,0.8,7.9,3.9,6.5,7.4C104.6,35.7,101.2,37.1,98.7,37.4\" />"
    + "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" id=\"XMLID_373_\" d=\"M19.1,78.7c-3.7-1.4-6.9-8.6-2.4-10.4c0.1-0.6,0.7-1.3,1.2-1.5c0-0.1,0-0.2,0-0.3"
    + "c3.5-3.4,5.9-8.2,8.9-12c0.8-1.4,1.2-2.8,2.8-3.2c0.8,0.7,0.5,2.4,0.3,3.6c0.4,0.3,1.6,0.1,2.4-0.2c2.5-2.1,5.7-4,8.1-6.2"
    + "c0.1-1.1,0.3-2.2,0.4-3.2c-1.7,0.4-7.4,1.7-6-1.4c2.1-0.8,5.3-2.7,6.5-4.9c0.6-2.3,0.2-4.9,1.4-6.6c2.4-1.2,5.2,1.8,5.7,4.3"
    + "c1,1.7,3.9-0.4,0.2,4.8c-0.8,0.6-0.7,1.7-0.6,2.9c0.3,0,0.5,0,0.8,0.1c2.1-1.5,4.3-3.1,6.7-4.5c0.6-3.3,1.2-6.1,2.8-8.9"
    + "c2.3-1.6,5.4,0.1,7.7,1.9c1.7-0.1,2.8-0.8,4.4-2c0.6-0.2,0.6-0.2,1.8-0.2c0.5,0.8,0.6,1.7,0.7,2.9c-1.1,3.4-10.8,4.5-9,8.5"
    + "c1.7-0.1,2.3-2,2.9-3.2c1.9-1,6,0.2,8,1.7c2.2,2.7,0.5,3.6-2,5.3c-0.2,0.4-0.5,0.7-0.7,1.1c-0.2,5.4-0.2,5.4-0.1,12.8"
    + "c-0.8,2-1.4,3-3,4.6c0,0.1,0,0.2,0,0.2c-0.1,0-0.2,0-0.3,0c-0.9,1.6-3.2,3.3-4.6,1.7c0-6,0.3-12.3,0.1-18.1"
    + "c-0.1,0-0.2,0.1-0.3,0.1c-0.4,2.9-3.4,8.5-5.9,10.3c-2.3,0.1-4.3-1.2-4.9-3.2c0.2-0.6,0.7-0.7,1.2-1.2c1.3-2.7,0.9-7.6,0.9-10.3"
    + "c-1.9,0.3-5.1,4.5-6.5,6.1c-1,0.8-1.9,1.5-2.8,2.3c-0.7,2.2-1.2,4.5-1.8,6.9c-0.5,1.1-1,2.2-1.5,3.3c-0.1,0-0.2,0-0.3,0"
    + "c-0.9,1.5-3.7,5.4-5.4,2.9c0-0.3,0-0.7,0-1c1.4-2.1,2.5-5,2.6-7.4c-2.3,0.8-3.9,2.9-6.2,3c-1.3-0.3-2.7-0.7-3.6-1.1"
    + "c0-0.1,0-0.2,0-0.3c-0.6-0.4-1.1-0.9-1.5-0.7c-0.4,1.3-0.8,2.7-1.2,4c-2.4,5-4.1,9.9-5.7,15.4C20.3,78.4,20,78.5,19.1,78.7\" />"
    + "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" id=\"XMLID_372_\" d=\"M23.6,50c-0.7-1,0.2-2.4,0.2-3.6c-1.1-3.4-2-6,0.1-8.8c0.3-0.1,0.7-0.1,1-0.1"
    + "c1.6,1.1,3.8,3.6,5.2,5.5C31.9,46.9,26.6,48.8,23.6,50\" />"
    + "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" id=\"XMLID_371_\" d=\"M26.9,36.7c-0.9-0.3-0.8-0.5-1-0.8c0.4-0.8,0.8-1.3,0.6-2.2c-2.1-3.2-2-8.1,1.6-9.7"
    + "c1.1,0.1,1.1,1,1.5,2.5c2.4,2.3,6.7,5.1,2.6,8.2C30.6,35.5,28.7,36.1,26.9,36.7\" />"
    + "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" id=\"XMLID_370_\" d=\"M201.6,49.3c-3.3-1-2.7-6.4-2.1-8.6c2.4-1.5,5.5,1.6,5.7,4.5"
    + "C204.6,48.2,204.6,48.7,201.6,49.3\" />"
    + "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" id=\"XMLID_367_\" d=\"M219.3,74.1c-0.1-0.1-0.2-0.1-0.3-0.2c-4.2,0.3-8.2-0.1-11.9-1.5c-0.2-0.3-0.2-0.3-0.2-0.8"
    + "c2.2-1.3,5.3-0.9,7-3.3c0.3-1.8,0.5-3.4,0.3-4.9c-4.2,0.3-6.4,3.2-9.7,4.4c-2.8,0.2-7.8-2.4-8.7-4.6c0-3.6,0.8-2,4.6-2.2"
    + "c4.6-0.8,9.2-3.5,13.7-5.4c0.9-0.7,0.9-0.7,1.5-0.9c1-3,1.7-3.5,4.8-4.2c1.2-0.6,1.2-0.6,4.8-2.8c0.1-0.3,0.2-0.7,0.3-1.1"
    + "c-5.4,0.6-9.8,5-14.1,7.9c-2.1,0.6-3.8,0.2-5.3-0.4c-1,0.1-6.4,1.1-3.7-1.1c1.6-0.6,2.8-1.8,4.5-2.5c4.1-2.7,8.8-5.1,13.2-7.6"
    + "c0-0.7-0.3-1.1-0.4-1.2c0-0.9,0.2-1.4,0.4-2.1c-0.8,0.3-1.1,0.2-1.2,0.8c-2.6,1.2-3.7,3.5-5.9,1c-0.6,2.3-2.2,3.9-4.5,4"
    + "c-2.3-1.2-2.4-5.1-2.8-6.9c-0.2-0.2-0.5-1.7-1.1-3.5c-1.1-2.1-3-4.5-1.7-6.5c1.7-1,2.3-1.4,3.7,0.8c1.2,0.9,2.7,2.2,3.9,3.8"
    + "c0.1,0,0.2,0,0.3,0c0.7,2,2.5,4.6,2.4,7.1c1.2-0.7,3-2.1,2.1-3.7c-2-1.1-0.9-3,0.5-3.7c1,0.1,1,0.1,2.3-0.1"
    + "c0-0.5-0.1-0.5-0.3-0.8c-1.7-0.6-1.4-1-0.9-2.3c-2-0.7-2.7-2.8-1.9-4.2c5.7-1.4,5.7-1.4,8.3-2.3c1.8-2.2,3.7-8.2,7.1-7.1"
    + "c1.1,1.3,1.8,3.4,1.6,5.5c-0.4,0.9-1,1.7-1.2,2.7c0.3,0,0.7,0,1,0c2.4-1.2,3.5-2.6,4.9,1c2.3,1.2,3.1,0.9,2.3,4.3"
    + "c-1.7,3.3-3.5,6.9-5.3,10.3c0,0.2-0.1,0.3,0,0.5c0.4,0.1,0.9,0.2,1.3,0.3c0.2,1.5,0.3,3.4,0.2,5.2c-1.4,2.1-3.2,2.1-5.5,2.4"
    + "c-2.9,1.4-5.5,2.6-8.2,4.3c0,0.5-0.1,1.1,0.2,1.8c1.4,0,2.8-0.1,4.2-0.1c1.6,1,1.4,3.8,0.5,5.5c-1.6,0.2-2.5,0.4-3.8,1.1"
    + "c-0.1,0.8-0.3,1.5-0.4,2.4C222.2,66.1,223.8,73.4,219.3,74.1 M228.2,37c1.4-1.4,2.4-2.8,2.3-4.8c-1.2-1-3.2-1.2-4.4-1.1"
    + "c-0.2,0.5-0.2,0.5-1.6,3.2c0.1,0.1,0.3,0.1,0.4,0.2c-0.1,0-0.3,0.1-0.4,0.2c0,0.1,0.1,0.1,0.1,0.3c0.6,0.1,1-0.4,1.2-0.8"
    + "c2.2-0.4,2.2,0.4,2.1,2.8C228,36.9,228.1,36.9,228.2,37\" />"
    + "</svg>",
)

#let asset-zju-logo = image("zjulogo.svg", width: 80%)

#let project(
  theme: "project",
  block_theme: "default",
  course: "<course>",
  title: "<title>",
  title_size: 3em,
  cover_image_padding: 1em,
  cover_image_size: none,
  semester: "<semester>",
  name: none,
  author: none,
  school_id: none,
  date: none,
  college: none,
  place: none,
  teacher: none,
  major: none,
  cover_comments: none,
  cover_comments_size: 1.25em,
  language: none,
  table_of_contents: none,
  font_serif: (
    "New Computer Modern",
    "FandolSong",
    "Georgia",
    "Nimbus Roman No9 L",
    "SimSun",
    "Songti SC",
    "Noto Serif CJK SC",
    "Source Han Serif SC",
    "Source Han Serif CN",
    "STSong",
    "AR PL New Sung",
    "AR PL SungtiL GB",
    "NSimSun",
    "TW\-Sung",
    "WenQuanYi Bitmap Song",
    "AR PL UMing CN",
    "AR PL UMing HK",
    "AR PL UMing TW",
    "AR PL UMing TW MBE",
    "PMingLiU",
    "MingLiU",
  ),
  font_sans_serif: (
    "Noto Sans",
    "Helvetica Neue",
    "Helvetica",
    "Nimbus Sans L",
    "Arial",
    "Liberation Sans",
    "PingFang SC",
    "Hiragino Sans GB",
    "Noto Sans CJK SC",
    "Source Han Sans SC",
    "Source Han Sans CN",
    "Microsoft YaHei",
    "Wenquanyi Micro Hei",
    "WenQuanYi Zen Hei",
    "ST Heiti",
    "SimHei",
    "WenQuanYi Zen Hei Sharp",
  ),
  font_mono: ("Consolas", "Monaco"),
  body,
) = {
  font_mono = (..font_mono, ..font_sans_serif)
  if (theme == "lab") {
    if (cover_image_size == none) {
      cover_image_size = 48%
    }
  } else if (theme == "project") {
    if (cover_image_size == none) {
      cover_image_size = 50%
    }
    if (language == none) {
      language = "en"
    }
    if (table_of_contents == none) {
      table_of_contents = true
    }
  } else if (theme == "journal") {
    if (language == none) {
      language = "cn"
    }
    if (table_of_contents == none) {
      table_of_contents = false
    }
  }
  // fallback
  if (language == none) {
    language = "cn"
  }
  if (table_of_contents == none) {
    table_of_contents = false
  }

  set document(author: (author), title: title)

  if (theme == "journal") {
    set page(
      paper: "a4",
      margin: (x: 18mm, y: 18mm),
      numbering: "1",
      number-align: center,
    )
  } else {
    set page(numbering: "1", number-align: center)
  }

  let body_text_size = if theme == "journal" { 10pt } else { 10pt }
  set text(font: font_serif, lang: language, size: body_text_size)
  show raw: set text(font: font_mono)
  show math.equation: set text(weight: 400)

  if (theme == "journal") {
    set par(spacing: 0.55em, leading: 0.82em)
  } else {
    set par(spacing: 0.85em, leading: 0.75em)
  }

  // Update global state
  state-course.update(course)
  state-author.update(author)
  state-school-id.update(school_id)
  state-date.update(date)
  state-theme.update(theme)
  state-block-theme.update(block_theme)

  // Cover Page
  if (theme == "lab") {
    v(1fr)
    {
      set align(center)
      block(width: cover_image_size, asset-zju-banner)
      text(size: 26pt, fakebold[本科实验报告])
    }
    v(2fr)
    let rows = ()
    if (course != none) {
      rows.push("课程名称")
      rows.push(course)
    }
    if (name != none) {
      rows.push("实验名称")
      rows.push(name)
    }
    if (author != none) {
      rows.push([姓$space.quad space.quad$名])
      rows.push(author)
    }
    if (school_id != none) {
      rows.push([学$space.quad space.quad$号])
      rows.push(school_id)
    }
    if (college != none) {
      rows.push([学$space.quad space.quad$院])
      rows.push(college)
    }
    if (major != none) {
      rows.push([专$space.quad space.quad$业])
      rows.push(major)
    }
    if (place != none) {
      rows.push([实验地点])
      rows.push(place)
    }
    if (teacher != none) {
      rows.push([指导教师])
      rows.push(teacher)
    }
    if (date != none) {
      rows.push([报告日期])
      rows.push(date)
    }
    align(
      center,
      box(width: 75%)[
        #set text(size: 1.2em)
        #tablex(
          columns: (6.5em + 5pt, 1fr),
          align: center + horizon,
          stroke: 0pt,
          // stroke: 0.5pt + red, // this line is just for testing
          inset: 1pt,
          map-cells: cell => {
            if (cell.x == 0) {
              _underlined_cell([#cell.content#"："], color: white)
            } else {
              _underlined_cell(cell.content, color: black)
            }
          },
          ..rows,
        )
      ],
    )
    v(2fr)
    pagebreak()
  } else if (theme == "project") {
    v(1fr)
    box(
      width: 100%,
      {
        set align(center)

        v(cover_image_padding)
        block(width: cover_image_size, asset-zju-logo)
        v(cover_image_padding)

        par(text(font: "FandolHei", size: 2em, weight: 700, course))
        
        v(1em)

        par(text(font: ("New Computer Modern", "FandolHei"), size: 1.5em, weight: 400, title))

        if cover_comments == none {
          text(cover_comments_size)[
            #v(1em)
            #if (author != none) [
              Author: #author
            ]

            Date: #date

            #semester Semester
          ]
        } else {
          // If cover_comments is assigned, it will be used as the cover's original comments
          cover_comments
        }
      },
    )
    v(4fr)
    pagebreak()
  } else if (theme == "journal") {
    {
      set align(center)
      block(width: 100%, below: 0.9em)[
        #set par(first-line-indent: 0em, spacing: 0.45em, leading: 0.55em)
        #text(font: (..font_serif, ..font_sans_serif), size: 16pt, weight: 700, title)
        #v(0.35em)
        #if (author != none) [
          #text(size: 10pt, author)
        ]
        #if (course != none or college != none or major != none) [
          #text(size: 8.6pt, fill: luma(35))[
            #if (college != none) [#college]
            #if (college != none and major != none) [，]
            #if (major != none) [#major]
            #if ((college != none or major != none) and course != none) [；]
            #if (course != none) [#course]
          ]
        ]
        #if (date != none) [
          #text(size: 8.6pt, fill: luma(35), date)
        ]
      ]
    }
  } else if (theme == "nocover") {
    // no cover page
  } else {
    set text(fill: red, size: 3em, weight: 900)
    align(center)[Theme not found!]
    pagebreak()
  }

  if (table_of_contents) {
    {
      set align(center)
      set par(leading: 1em)
      outline(title: text(1.1em, "目录"), depth: 3, indent: auto)
    }
    pagebreak()
  }

  set par(justify: true)
  set table(align: center + horizon, stroke: 0.5pt)
  set figure.caption(separator: ".")

  show raw.where(block: false): it => box(it, fill: luma(240), stroke: luma(160) + 0.5pt, inset: (left: 0.25em, right: 0.25em), outset: (top: 0.35em, bottom: 0.35em), radius: 0.35em)

  set heading(
    numbering: (..args) => {
      let nums = args.pos()
      if nums.len() == 1 {
        return numbering("1  ", ..nums)
      } else if nums.len() == 2 {
        return numbering("1.1  ", ..nums)
      } else {
        return numbering("1.1.1  ", ..nums)
      }
    },
  )
  show heading: it => {
    block(above: 1.2em, below: 0.55em, it)
  }
  show heading.where(level: 1): it => {
    set text(size: 1.1em, weight: 700)
    block(above: 1.5em, below: 0.85em, it)
  }
  show heading.where(level: 2): it => {
    set text(size: 1em, weight: 700)
    block(above: 1.1em, below: 0.5em, it)
  }
  show heading.where(level: 3): it => {
    set text(size: 1em, weight: 600, style: "italic")
    block(above: 0.9em, below: 0.4em, it)
  }
  if (theme == "lab") {
    set heading(
      numbering: (..args) => {
        let nums = args.pos()
        if nums.len() == 1 {
          return none
        } else if nums.len() == 2 {
          return numbering("一、", ..nums.slice(1))
        } else {
          return numbering("1.1.", ..nums.slice(1))
        }
      },
    )

    show heading.where(level: 1): it => block(
      width: 100%,
      above: 2em,
      below: 1.5em,
      {
        set align(center)
        set text(size: 1.2em)
        it
      },
    )

    body
  } else if (theme == "journal") {
    // Journal theme: remove gray background box from inline code
    show raw.where(block: false): it => it

    set figure(supplement: "图")
    set figure.caption(separator: "  ")
    set figure(placement: none)

    set heading(
      numbering: (..args) => {
        let nums = args.pos()
        if nums.len() == 1 {
          return numbering("1. ", ..nums)
        } else if nums.len() == 2 {
          return numbering("1.1 ", ..nums)
        } else {
          return numbering("1.1.1 ", ..nums)
        }
      },
    )
    show heading: it => block(above: 0.85em, below: 0.35em, it)
    show heading.where(level: 1): it => {
      set text(size: 11pt, weight: 700)
      block(above: 1em, below: 0.45em, it)
    }
    show heading.where(level: 2): it => {
      set text(size: 10pt, weight: 700)
      block(above: 0.75em, below: 0.3em, it)
    }
    show heading.where(level: 3): it => {
      set text(size: 9.6pt, weight: 600, style: "italic")
      block(above: 0.7em, below: 0.45em, it)
    }
    body
  } else {
    body
  }
}

#let codex(code, lang: none, filename: none, size: 1em, stroke: 0.5pt + luma(150), inset: 1em, radius: 0.25em) = {
  if code.len() > 0 {
    if code.ends-with("\n") {
      code = code.slice(0, code.len() - 1)
    }
  } else {
    code = "// code not found"
  }

  set text(size: size)
  set align(left)
  if filename != none {
    block(
      width: 100%,
      stroke: stroke,
      radius: radius,
      clip: true,
      stack(
        {
          block(width: 100%, inset: inset, filename)
        },
        line(length: 100%, stroke: stroke),
        block(width: 100%, inset: inset, raw(lang: lang, block: true, code)),
      ),
    )
  } else {
    block(width: 100%, stroke: stroke, radius: radius, inset: inset, raw(lang: lang, block: true, code))
  }
}

#let lab_header(
  course: none,
  type: "综合",
  name: "<name>",
  author: none,
  school_id: none,
  place: "<place>",
  date: none,
) = {
  pagebreak(weak: true)
  align(center)[
    #set text(size: 1.5em)
    #fakebold[浙江大学实验报告]
  ]
  tablex(
    columns: (1fr, 0.32fr, 1.68fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    stroke: 0pt,
    inset: 1pt,
    _underlined_cell("课程名称：", color: white),
    colspanx(
      2,
      _underlined_cell(if course == none {
        context state-course.get()
      } else {
        course
      }),
    ),
    (),
    _underlined_cell("实验类型：", color: white),
    colspanx(2, _underlined_cell(type)),
    (),
    colspanx(2, _underlined_cell("实验项目名称：", color: white)),
    (),
    colspanx(4, _underlined_cell(name)),
    (),
    (),
    (),
    _underlined_cell("学生姓名：", color: white),
    colspanx(
      2,
      _underlined_cell(if author == none {
        context state-author.get()
      } else {
        author
      }),
    ),
    (),
    _underlined_cell([学$space.quad space.quad$号：], color: white),
    colspanx(
      2,
      _underlined_cell(if school_id == none {
        context state-school-id.get()
      } else {
        school_id
      }),
    ),
    (),
    _underlined_cell("实验地点：", color: white),
    colspanx(2, _underlined_cell(place)),
    (),
    _underlined_cell("实验日期：", color: white),
    colspanx(
      2,
      _underlined_cell(if date == none {
        context state-date.get()
      } else {
        date
      }),
    ),
    (),
  )
}

#let lab_header_2(
  major: none,
  author: none,
  school_id: none,
  date: none,
  course: none,
  teacher: none,
  grade: none,
  name: none,
) = {
  align(center)[
    #grid(
      columns: 3,
      column-gutter: (-15pt, 20pt),
      [
        #block(width: 75%, asset-zju-banner)
      ],
      [
        #text(size: -10pt)[] \ #text(size: 30pt, stroke: 1pt)[实验报告]
      ],
      [
        #align(left)[
          #text(size: 1em)[
            专业：#major\
            姓名：#author \
            学号：#school_id \
            日期：#date\
          ]
        ]
      ],
    )
  ]

  tablex(
    columns: (1.3fr, 2fr, 1.3fr, 1fr, 1fr, 0.5fr),
    align: left,
    stroke: 0pt,
    inset: 1pt,
    _underlined_cell("课程名称：", color: white),
    colspanx(
      1,
      _underlined_cell(if course == none {
        context state-course.get()
      } else {
        course
      }),
    ),
    _underlined_cell("指导老师：", color: white),
    colspanx(1, _underlined_cell(teacher)),
    _underlined_cell("成绩：", color: white),
    colspanx(1, _underlined_cell(grade)),
    _underlined_cell("实验名称：", color: white),
    colspanx(4, _underlined_cell(name)),
    (),
    (),
    (),
  )
}

#let table3(
  // 三线表
  ..args,
  inset: 0.5em,
  stroke: 0.5pt,
  cell-align: center + horizon,
  columns: 1fr,
  size: 8.8pt,
  width: auto,
) = {
  align(center)[
    #block(width: width)[
      #set text(size: size)
      #tablex(
        columns: (auto,),
        inset: 0pt,
        stroke: 0pt,
        map-hlines: h => {
          if (h.y > 0) {
            (..h, stroke: (stroke * 2) + black)
          } else {
            h
          }
        },
        tablex(
          ..args,
          inset: inset,
          stroke: stroke,
          align: cell-align,
          columns: columns,
          map-cells: cell => {
            if (cell.y == 0) {
              strong(cell.content)
            } else {
              cell.content
            }
          },
          map-hlines: h => {
            if (h.y == 0) {
              (..h, stroke: (stroke * 2) + black)
            } else if (h.y == 1) {
              (..h, stroke: stroke + black)
            } else {
              (..h, stroke: 0pt)
            }
          },
          auto-vlines: false,
        ),
      )
    ]
  ]
}

#let tablecaption(it) = {
  block(width: 100%, above: 0.35em, below: 0.25em)[
    #set align(center)
    #set text(size: 8pt, weight: 500)
    #it
  ]
}

#let figurex(img, caption) = {
  show figure.caption: it => {
    block(above: 0.2em, below: 0.55em, width: 100%)[
      #set align(center)
      #set text(size: 0.84em, fill: luma(40), weight: 400)
      #it
    ]
  }
  figure(
    kind: image,
    img,
    caption: [
      #set text(weight: 400)
      #caption
    ],
  )
}

#let figurewide(img, caption) = {
  show figure.caption: it => {
    block(above: 0.2em, below: 0.6em, width: 100%)[
      #set align(center)
      #set text(size: 0.84em, fill: luma(40), weight: 400)
      #it
    ]
  }
  block(width: 100%, above: 0.45em, below: 0.45em)[
    #figure(
      kind: image,
      block(width: 98%, img),
      caption: [
        #set text(weight: 400)
        #caption
      ],
    )
  ]
}

#let tablewide(caption, body) = {
  block(width: 100%, above: 0.45em, below: 0.45em)[
    #tablecaption(caption)
    #body
  ]
}

#let tablefit(caption, body) = {
  block(width: 100%, above: 0.45em, below: 0.45em)[
    #tablecaption(caption)
    #body
  ]
}

#let blockx(it, name: "", color: red, theme: none) = {
  context {
    let _theme = theme
    if (_theme == none) {
      _theme = state-block-theme.get()
    }
    if (_theme == "default") {
      let _inset = 0.8em
      let _color = color.darken(5%)
      v(0.2em)
      block(below: 1em, stroke: 0.5pt + _color, radius: 3pt, width: 100%, inset: _inset)[
        #place(
          top + left,
          dy: -6pt - _inset, // Account for inset of block
          dx: 8pt - _inset,
          block(fill: white, inset: 2pt)[
            #set text(font: "Noto Sans", fill: _color)
            #name
          ],
        )
        #set text(fill: _color)
        #set par(first-line-indent: 0em)
        #it
      ]
    } else if (_theme == "boxed") {
      showybox(
        title: name,
        frame: (
          border-color: color,
          title-color: color.lighten(20%),
          body-color: color.lighten(95%),
          footer-color: color.lighten(80%),
        ),
        it,
      )
    } else if (_theme == "float") {
      showybox(
        title-style: (
          boxed-style: (anchor: (x: center, y: horizon), radius: (top-left: 10pt, bottom-right: 10pt, rest: 0pt)),
        ),
        frame: (
          title-color: color.darken(5%),
          body-color: color.lighten(95%),
          footer-color: color.lighten(60%),
          border-color: color.darken(20%),
          radius: (top-left: 10pt, bottom-right: 10pt, rest: 0pt),
        ),
        title: name,
        [
          #it
          #v(0.25em)
        ],
      )
    } else if (_theme == "thickness") {
      showybox(
        title-style: (color: color.darken(20%), sep-thickness: 0pt, align: center),
        frame: (title-color: color.lighten(85%), border-color: color.darken(20%), thickness: (left: 1pt), radius: 0pt),
        title: name,
        it,
      )
    } else if (_theme == "dashed") {
      showybox(
        title: name,
        frame: (
          border-color: color,
          title-color: color,
          radius: 0pt,
          thickness: 1pt,
          body-inset: 1em,
          dash: "densely-dash-dotted",
        ),
        it,
      )
    } else {
      block(
        width: 100%,
        stroke: 0.5pt + red,
        inset: 1em,
        radius: 0.25em,
        align(center, text(fill: red, size: 1.2em, weight: "bold", [Unknown block theme!])),
      )
    }
  }
}

#let example(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Example")
  },
  color: gray.darken(60%),
)
#let proof(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Proof")
  },
  color: rgb(120, 120, 120),
)
#let abstract(it, name: none) = {
  let title = if (name != none) {
    name
  } else {
    strong("摘要")
  }
  block(width: 100%, above: 0.55em, below: 0.25em, inset: (left: 0em, right: 0em, top: 0.25em, bottom: 0.2em))[
    #set text(size: 8.4pt)
    #set par(first-line-indent: 0em, justify: true, spacing: 0.55em, leading: 0.65em)
    #align(center)[
      #set text(size: 9pt, weight: 700)
      #title
    ]
    #v(0.35em)
    #it
  ]
}

#let keywords(it, name: none, separator: none) = {
  let label = if (name != none) {
    name
  } else {
    "关键词"
  }
  let sep = if (separator != none) {
    separator
  } else if (label == "Keywords") {
    ": "
  } else {
    "："
  }
  block(width: 100%, above: 0em, below: 0.55em, inset: (left: 0em, right: 0em, top: 0em, bottom: 0em))[
    #set text(size: 8.4pt)
    #set par(first-line-indent: 0em, justify: true, spacing: 0.45em, leading: 0.6em)
    #strong(label)#sep#it
  ]
}
#let summary(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Summary")
  },
  color: rgb(0, 133, 143),
)
#let info(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Info")
  },
  color: rgb(68, 115, 218),
)
#let note(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Note")
  },
  color: rgb(68, 115, 218),
)
#let tip(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Tip")
  },
  color: rgb(0, 133, 91),
)
#let hint(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Hint")
  },
  color: rgb(0, 133, 91),
)
#let success(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Success")
  },
  color: rgb(62, 138, 0),
)
#let important(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Important")
  },
  color: rgb(62, 138, 0),
)
#let help(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Help")
  },
  color: rgb(153, 110, 36),
)
#let warning(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Warning")
  },
  color: rgb(184, 95, 0),
)
#let attention(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Attention")
  },
  color: rgb(216, 58, 49),
)
#let caution(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Caution")
  },
  color: rgb(216, 58, 49),
)
#let failure(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Failure")
  },
  color: rgb(216, 58, 49),
)
#let danger(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Danger")
  },
  color: rgb(216, 58, 49),
)
#let error(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Error")
  },
  color: rgb(216, 58, 49),
)
#let bug(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Bug")
  },
  color: rgb(204, 51, 153),
)
#let quote(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Quote")
  },
  color: rgb(132, 90, 231),
)
#let cite(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Cite")
  },
  color: rgb(132, 90, 231),
)
#let experiment(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Experiment")
  },
  color: rgb(132, 90, 231),
)
#let question(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Question")
  },
  color: rgb(132, 90, 231),
)
#let analysis(it, name: none) = blockx(
  it,
  name: if (name != none) {
    name
  } else {
    strong("Analysis")
  },
  color: rgb(0, 133, 91),
)
