#let template(
	// The paper's title.
	title: "Paper Title",
	subtitle: none,
	// An array of authors. For each author you can specify a name, orcid, and affiliations.
	// affiliations should be content, e.g. "1", which is shown in superscript and should match the affiliations list.
	// Everything but the name is optional.
	authors: (),
	// This is the affiliations list. Include an id and `name` in each affiliation. These are shown below the authors.
	affiliations: (),
	// The paper's abstract. Can be omitted if you don't have one.
	abstract: none,
	// The short-title is shown in the running header
	short-title: none,
	// The short-citation is shown in the running header, if set to auto it will show the author(s) and the year in APA format.
	short-citation: auto,
	// The venue is show in the footer
	venue: none,
	// An image path that is shown in the top right of the page. Can also be content.
	logo: none,
	// A DOI link, shown in the header on the first page. Should be just the DOI, e.g. `10.10123/123456` ,not a URL
	doi: none,
	heading-numbering: "1.1.1",
	// Show an Open Access badge on the first page, and support open science, default is true, because that is what the default should be.
	open-access: true,
	// A list of keywords to display after the abstract
	keywords: (),
	// The "kind" of the content, e.g. "Original Research", this is shown as the title of the margin content on the first page.
	kind: none,
	// Content to put on the margin of the first page
	// Should be a list of dicts with `title` and `content`
	margin: (),
	paper-size: "a4",
	// A color for the theme of the document
	theme: blue.darken(30%),
	// Date published, for example, when you publish your preprint to an archive server.
	// To hide the date, set this to `none`. You can also supply a list of dicts with `title` and `date`.
	date: datetime.today(),
	// Feel free to change this, the font applies to the whole document
	font-face: "Alegreya Sans",
	// The path to a bibliography file if you want to cite some external works.
	bibliography-file: none,
	bibliography-style: "apa",
	// The paper's content.
	body
) = {

	/* Logos */
	let orcidSvg = ```<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 24 24"> <path fill="#AECD54" d="M21.8,12c0,5.4-4.4,9.8-9.8,9.8S2.2,17.4,2.2,12S6.6,2.2,12,2.2S21.8,6.6,21.8,12z M8.2,5.8c-0.4,0-0.8,0.3-0.8,0.8s0.3,0.8,0.8,0.8S9,7,9,6.6S8.7,5.8,8.2,5.8z M10.5,15.4h1.2v-6c0,0-0.5,0,1.8,0s3.3,1.4,3.3,3s-1.5,3-3.3,3s-1.9,0-1.9,0H10.5v1.1H9V8.3H7.7v8.2h2.9c0,0-0.3,0,3,0s4.5-2.2,4.5-4.1s-1.2-4.1-4.3-4.1s-3.2,0-3.2,0L10.5,15.4z"/></svg>```.text
	let mailSvg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 199.2 199.3" xmlns:v="https://vecta.io/nano"><path d="M99.6 199.3c54.5 0 99.6-45.1 99.6-99.6C199.2 45.3 154 .1 99.5.1 45.1.1 0 45.3 0 99.7c0 54.5 45.2 99.6 99.6 99.6z" opacity=".49" fill="#404040" fill-opacity=".25"/><path d="M99.6 105c-1.5 0-3.1-.6-4.6-2L45.4 59.3c2.7-1.7 5.7-2.3 9.9-2.3H144c4 0 7 .8 9.9 2.4L104.2 103c-1.5 1.4-3 2-4.6 2zM41 134.4c-.9-2-1.4-4.1-1.4-7.2V72.3c0-3.2.7-5.8 1.2-6.8l36.6 32.3L41 134.4zm12.8 8.1c-3.5 0-6.2-.8-8.2-2.1l37.7-37.6 7.1 6.3c2.8 2.5 6.1 3.8 9.2 3.8s6.3-1.3 9.3-3.8l7-6.3 37.7 37.6c-2 1.2-4.7 2.1-8.2 2.1H53.8zm104.5-8.1l-36.6-36.6 36.7-32.2c.5 1 1.1 3.5 1.1 6.7v54.9c0 3-.4 5.2-1.2 7.2z" fill="#7e8c7b"/></svg>```.text

	let spacer = text(fill: gray)[#h(8pt) | #h(8pt)]

	//date = "2023-11-19"
	let dates;
	if (date == "datetime") {
		dates = ((title: "Published", date: date),)
	}else if (type(date) == "dictionary") {
		dates = (date,)
	} else if (type(date) == "string") {
		//string as YYYY-MM-DD
		let bits = date.split("-")
		dates = ((title: "Published", date: datetime(year: int(bits.at(0)), month: int(bits.at(1)), day: int(bits.at(2)))),)
	} else {
		dates = date
	}

	date = dates.at(0).date

	// Create a short-citation, e.g. Cockett et al., 2023
	let year = if (date != none) { ", " + date.display("[year]") }
	if (short-citation == auto and authors.len() == 1) {
		short-citation = authors.at(0).name.split(" ").last() + year
	} else if (short-citation == auto and authors.len() == 2) {
		short-citation = authors.at(0).name.split(" ").last() + " & " + authors.at(1).name.split(" ").last() + year
	} else if (short-citation == auto and authors.len() > 2) {
		short-citation = authors.at(0).name.split(" ").last() + " " + emph("et al.") + year
	}

	// Set document metadata.
	set document(title: title, author: authors.map(author => author.name))

	show link: it => [#text(fill: theme)[#it]]
	show ref: it => [#text(fill: theme)[#it]]

	set page(
		paper-size,
		margin: (left: 25%),
		header: context {
			if here().position().page == 1 {
				let headers = (
					if (open-access) {smallcaps[Open Access]},
					if (doi != none) { link("https://doi.org/" + doi, "DOI: " + doi)}
				)
				return align(left, text(size: 8pt, fill: gray, headers.filter(header => header != none).join(spacer)))
			} else {
				return align(right, text(size: 8pt, fill: gray.darken(50%),
					(short-title, short-citation).join(spacer)
				))
			}
		},
		footer: context block(
			width: 100%,
			stroke: (top: 1pt + gray),
			inset: (top: 8pt, right: 2pt),
			[
				#grid(columns: (75%, 25%),
					align(left, text(size: 9pt, fill: gray.darken(50%),
							(
								if(venue != none) {emph(venue)},
								if(date != none) {date.display("[month repr:long] [day], [year]")}
							).filter(t => t != none).join(spacer)
					)),
					align(right)[
						#text(
							size: 9pt, fill: gray.darken(50%)
						)[
							#counter(page).display() of #counter(page).final().first()
						]
					]
				)
			]
		)
	)

	// Set the body font.
	set text(font: font-face, size: 10pt)
	// Configure equation numbering and spacing.
	set math.equation(numbering: "(1)")
	show math.equation: set block(spacing: 1em)

	// Configure lists.
	set enum(indent: 10pt, body-indent: 9pt)
	set list(indent: 10pt, body-indent: 9pt)

	// Configure line numbering.	
	set par.line(numbering: none, numbering-scope: "page")

	// Configure headings.
	set heading(numbering: heading-numbering)
	
	show heading: it => {
		// Find out the final number of the heading counter.
		let levels = counter(heading).at(here())
		set text(10pt, weight: 400)
		if it.level == 1 [
			// First-level headings are centered smallcaps.
			// We don't want to number of the acknowledgment section.
			#let is-ack = it.body in ([Acknowledgment], [Acknowledgement])
			// #set align(center)
			#set text(if is-ack { 12pt } else { 14pt })
			#show: smallcaps
			#v(20pt, weak: true)
			#if it.numbering != none and not is-ack {
				numbering(heading-numbering, ..levels)
				[.]
				h(7pt, weak: true)
			}
			#it.body
			#v(14pt, weak: true)
		] else if it.level == 2 [
			// Second-level headings are run-ins.
			#set par(first-line-indent: 0pt)
			#set text(12pt, style: "italic")
			#v(20pt, weak: true)
			#if it.numbering != none {
				numbering(heading-numbering, ..levels)
				[.]
				h(7pt, weak: true)
			}
			#it.body
			#v(14pt, weak: true)
		] else [
			// Third level headings are run-ins too, but different.
			#if it.level == 3 {
				numbering(heading-numbering, ..levels)
				[. ]
			}
			_#(it.body):_
		]
	}


	if (logo != none) {
		place(
			top,
			dx: -33%,
			float: false,
			box(
				width: 27%,
				{
					if (logo == "content") {
						logo
					} else {
						image(logo, width: 100%)
					}
				},
			),
		)
	}


	// Title and subtitle
	box(inset: (bottom: 2pt), text(17pt, weight: "bold", fill: theme, title))
	if subtitle != none {
		parbreak()
		box(text(14pt, fill: gray.darken(30%), subtitle))
	}
	// Authors and affiliations
	if authors.len() > 0 {
		box(inset: (y: 10pt), {
			authors.map(author => {
				text(11pt, weight: "semibold", author.name)
				h(1pt)
				if "affiliations" in author {
					super(author.affiliations)
				}
				if "email" in author {
					link("mailto://" + author.email)[#box(height: 1.1em, baseline: 13.5%)[#image.decode(mailSvg)]]
				}
				if "orcid" in author {
					link("https://orcid.org/" + author.orcid)[#box(height: 1.1em, baseline: 13.5%)[#image.decode(orcidSvg)]]
				}
			}).join(", ", last: ", and ")
		})
	}
	if affiliations.len() > 0 {
		box(inset: (bottom: 10pt), {
			affiliations.map(affiliation => {
				super(affiliation.id)
				h(1pt)
				affiliation.name
			}).join(", ")
		})
	}


	place(
		left + bottom,
		dx: -33%,
		dy: -10pt,
		box(width: 27%, {
			if (kind != none) {
				set par(spacing: 0em)
				text(11pt, fill: theme, weight: "semibold", smallcaps(kind))
				parbreak()
			}
			if (dates != none) {
				let formatted-dates

				grid(columns: (40%, 60%), gutter: 7pt,
					..dates.zip(range(dates.len())).map((formatted-dates) => {
						let d = formatted-dates.at(0);
						let i = formatted-dates.at(1);
						let weight = "light"
						if (i == 0) {
							weight = "bold"
						}
						return (
							text(size: 7pt, fill: theme, weight: weight, d.title),
							text(size: 7pt, d.date.display("[month repr:short] [day], [year]"))
						)
					}).flatten()
				)
			}
			v(2em)
			grid(columns: 1, gutter: 2em, ..margin.map(side => {
				text(size: 7pt, {
					if ("title" in side) {
						text(fill: theme, weight: "bold", side.title)
						[\ ]
					}
					set enum(indent: 0.1em, body-indent: 0.25em)
					set list(indent: 0.1em, body-indent: 0.25em)
					side.content
				})
			}))
		}),
	)

	set par.line(numbering: (n) => text(fill: rgb(175,130,130), size: 7pt, str(n)))
	
	if (abstract != none) {
		let abstracts
		if (abstract == "content") {
			abstracts = (title: "Abstract", content: abstract)
		} else {
			abstracts = abstract
		}

		box(inset: (top: 16pt, bottom: 16pt), stroke: (top: 1pt + gray, bottom: 1pt + gray), {

			abstracts.map(abs => {
				set par(justify: true)
				text(fill: theme, weight: "semibold", size: 9pt, abs.title)
				parbreak()
				abs.content
			}).join(parbreak())
		})
	}
	if (keywords.len() > 0) {
		parbreak()
		text(size: 9pt, {
			text(fill: theme, weight: "semibold", "Keywords")
			h(8pt)
			keywords.join(", ")
		})
	}
	v(10pt)

	show figure.caption: it => [
		#set par(justify: true, leading: 0.8em)
		#set text(discretionary-ligatures: false, number-type: "lining")
		#strong[#it.supplement #context { it.counter.display(it.numbering) }]: #it.body
		#v(1em)
	]

	set par(spacing: 1.5em)
	
	// Display the paper's contents.
	body

	// Display the bibliography.
	if (bibliography-file != none) {
		pagebreak(weak: true)
		set par.line(numbering: none)
		set par(spacing: 1em)
		show bibliography: set text(10pt)
		bibliography(bibliography-file, title: text(12pt, "References"), style: bibliography-style)
	}
}
