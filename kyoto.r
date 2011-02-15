REBOL
[
	Title: "Kyoto Tycoon API"
	Date: 15-Feb-2011
	Version: 0.1.0
	File: %kyoto.r
	Home: http://github.com/moechofe/KyoyoTycoon
	Author: {martin mauchauffée}
	Rights: {Copyleft}
	Tabs: 2
	History: [
		0.1.0 {Add SET command. Able to choose the DB and set the expiration time.}
	]
	Language: 'English
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tool]
		domain: [protocol database]
		tested-under: [core 2.7.6.3.1 Windows XP]
		tested-under: [core 2.7.8.4.2 Ubuntu]
		license: 'Copyleft
		see-also: [%test.r] ]
]

collect: func [ [throw] "Collects block evaluations."
'word "Word to collect (as a set-word! in the block)"
block [any-block!] "Block to evaluate"
/into dest [series!] "Where to append results"
/only "Insert series results as series"
/local code marker at-marker? marker* mark replace-marker rules ] [
	block: copy/deep block
	dest: any [dest make block! []]
	code: compose [first back (pick [insert insert/only] not only) tail dest]
	marker: to set-word! word
	at-marker?: does [mark/1 = marker]
	replace-marker: does [change/part mark code 1]
	marker*: [mark: set-word! (if at-marker? [replace-marker])]
	parse block rules: [any [marker* | into rules | skip]]
	do block
	head :dest ]

url-encode: func [ "URL-encode a string"
  data [string!] "String to encode"
/local normal-char ] [
	normal-char: (charset [ #"A" - #"Z" #"a" - #"z" #"@" #"." #"*" #"-" #"_" #"0" - #"9" ])
	collect/into ch [ forall data [ ch: either find normal-char first data
		[ first data ]
		[ rejoin ["%" to-string skip tail (to-hex to-integer first data) -2] ] ] ] copy "" ]

kyoto: func [ "Return a function able to send commands to a KyotoTycoon server."
url [url!] "The URL of the server. Format: http://localhost:1978" ] [

	do compose/deep [
	func [ {Send query or send command to a Tokyo Tycon server and receive result from it.

     Set a record:
     ----
     k/set "japan" "toyko"
     k/set/expire "japan" "kyoto" 123 ; Optional. The expiration time.
     k/set/data "mybase.kch" ; Optional. The database identifier.
     ----
}
	'key [unset! string! word! block!]
	/set value [string! unset!] "Set a value to a record."
	/get "Get a value from a record."
	/base DB [string! word! file!] "The database identifier."
	/expire xt [integer!] "The expiration time from now in seconds. If it is negative, the absolute value is treated as the epoch time."
	/local command arguments ] [
		arguments: copy []

		;unset? get/any 'key-or-query
		if set [ command: 'set
			arguments: [key value]
			if base [append arguments 'DB]
			if expire [append arguments 'xt] ]

		if value? arguments [
			arguments: collect/into key [ foreach keys arguments [ if not unset? get/any keys
			 [ key: rejoin [ keys "=" url-encode form get keys "&" ] ] ] ]
			 copy "" ]

		print read/custom rejoin [ (url) "/rpc/" command ] reduce [ 'post arguments ]

	] ] ]

; a: first k [ :a ]
; a: k/get 'a

; k/set 'a "b"
; k/set/db/expire 'a "b" "base" 123
; k [ /base 123 a: "b" ]
