REBOL
[
	Title: "Kyoto Tycoon API"
	Date: 16-Feb-2011
	Version: 0.2.0
	File: %kyoto.r
	Home: http://github.com/moechofe/KyoyoTycoon
	Author: {martin mauchauffée}
	Rights: {Copyleft}
	Tabs: 2
	History: [
		0.2.0 {Add GET command. Use a object instead of a function.}
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
  data [string!] "String to encode" ] [
	collect/into ch [ forall data [ ch: either find #{000000000064FF03FFFFFF87FEFFFF0700000000000000000000000000000000} first data
		[ first data ]
		[ rejoin ["%" to-string skip tail (to-hex to-integer first data) -2] ] ] ] copy "" ]

url-decode: func [ "URL-decode a string"
  data [string!] "String to decode" ] [
	collect/into ch [ forall data [ ch: either equal? #"%" first data
		[ data: skip data 2 to-char to-integer do join "#" copy/part back data 2 ]
		[ first data ] ] ] copy "" ]

kyoto: func [ "Return a function or an object able to send commands to a KyotoTycoon server."
url [url!] "The URL of the server. Format: http://localhost:1978" ] [

	do compose/deep [ context [

		add: func [ "Add a record."
		key [string! word! set-word!] "The key of th record."
		/expire 'xt [word!] "The expiration time from now in seconds. If it is negative, the absolute value is treated as the epoch time."
		/local in out ] [
		/local in out ] [
			in: join "key=" url-encode key

			if error? out: try [ parse read/custom (join url "/rpc/add") reduce ['post in] none ]
			[ out: disarm out switch/default out/code [
				450 [ return false ] ]
				[ make error! out ] ]

			if expire [ system/words/set :xt do select out "xt" ]
			if found? find out "value" [ return url-decode select out "value" ]
			none ]

		get: func [ "Get a record."
		key [string! word! set-word!] "The key of th record."
		/expire 'xt [word!] "The expiration time from now in seconds. If it is negative, the absolute value is treated as the epoch time."
		/local in out ] [
			in: join "key=" url-encode key

			if error? out: try [ parse read/custom (join url "/rpc/get") reduce ['post in] none ]
			[ out: disarm out switch/default out/code [
				450 [ return false ] ]
				[ make error! out ] ]

			if expire [ system/words/set :xt do select out "xt" ]
			if found? find out "value" [ return url-decode select out "value" ]
			none ]

		set: func [ [catch] "Set a record:"
		key [string! word! set-word!] "The key of th record."
		value [any-string!] "Set a value to a record."
		/base DB [string! word! file!] "The database identifier."
		/expire xt [integer!] "The expiration time from now in seconds. If it is negative, the absolute value is treated as the epoch time."
		/local in out ] [
			in: rejoin ["key=" url-encode key "&value=" url-encode value]
			if base [append in join "&DB=" DB]
			if expire [append in join "&xt=" xt]
			read/custom (join url "/rpc/set") reduce ['post in] ]

	] ] ]

; a: first k [ :a ]
; a: k/get 'a

; k/set 'a "b"
; k/set/db/expire 'a "b" "base" 123
; k [ /base 123 a: "b" ]
