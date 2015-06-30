fs = require('fs')

msgs = require( process.argv[2] or "./messages.json" )
marked = require('marked')

emoji = require( "emoji-images" )
escape = require('escape-html')

toMarkdown = require( "to-markdown" )
htmlMd = require( "html-md" )
html2markdown = require( "html2markdown" )

results = []

converters = [
	filter: 'div'
	replacement: ( ihtml, node )->
		if node.className is "wmquot"
			return "\n\n> " + ihtml + "\n\n"
		return ihtml
]
	

for msg, idx in msgs
	_c = emoji( msg, 'node_modules/emoji-images/pngs', 30 )
	results.push
		org: _c
		toMarkdown: [ ( _mda = toMarkdown( _c, gfm: false, converters: converters ) ), marked( _mda ) ]
		htmlMd: [ ( _mdb = htmlMd( _c ) ), marked( _mdb ) ]
		html2markdown: [ ( _mdc = html2markdown( _c ) ), marked( _mdc ) ]

sHTML = """
<!doctype html>
<html>
	<head>
		<meta charset="utf-8">
		<meta http-equiv="x-ua-compatible" content="ie=edge">
		<title>Compare HTML 2 Markdown</title>
		<meta name="description" content="">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
		<style>
			.wmquot, blockquote{
				border-left: 5px solid blue;
				font-size: 17.5px;
				margin: 0 0 20px;
				padding: 10px 20px;
				font-size: 14px;
			}
			.wmquot{
				border-left: 5px solid red;
			}
			code{
				overflow: hidden;
				white-space: pre-wrap;
				display:block;
			}
		</style>
	</head>
	<body>
		<table class="table table-bordered table-hover">
			<tr>
				<th width="4%"></th>
				<th width="24%">Original</th>
				<th width="24%"><a href="https://github.com/domchristie/to-markdown">to-markdown</a></th>
				<th width="24%"><a href="https://www.npmjs.com/package/html-md">html-md</a></th>
				<th width="24%"><a href="https://www.npmjs.com/package/html2markdown">html2markdown</a></th>
			</tr>
"""
for res, idx in results
	sHTML += "<tr>"
	sHTML += "<td>#{idx+1}</td>"
	sHTML += "<td>#{res.org}</td>"
	sHTML += "<td>#{res.toMarkdown[1]}</td>"
	sHTML += "<td>#{res.htmlMd[1]}</td>"
	sHTML += "<td>#{res.html2markdown[1]}</td>"
	sHTML += "</tr>"
	sHTML += "<tr>"
	sHTML += "<td>#{idx+1} SOURCE</td>"
	sHTML += "<td><code id=\"org#{idx}\" data-idx=\"#{idx}\" class=\"org\">#{escape(res.org)}</code></td>"
	sHTML += "<td class=\"md\"><code id=\"tm#{idx}\" class=\"tm\">#{escape(res.toMarkdown[0])}</code></td>"
	sHTML += "<td class=\"md\"><code>#{escape(res.htmlMd[0])}</code></td>"
	sHTML += "<td class=\"md\"><code>#{escape(res.html2markdown[0])}</code></td>"
	sHTML += "</tr>"

sHTML += """
		</table>
	</body>
</html>
"""

fs.writeFileSync( "./out.html", sHTML )
