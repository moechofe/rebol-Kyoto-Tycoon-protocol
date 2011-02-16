REBOL
[
	Title: "Kyoto Tycoon API test"
	Date: 16-Feb-2011
	Version: 0.1.1
	File: %test.r
	Home: http://github.com/moechofe/KyoyoTycoon
	Author: {martin mauchauffée}
	Rights: {Copyleft}
	Tabs: 2
	History: [
		0.1.1 {Add SET/GET test.}
		0.1.0 {Add Test::More style func.}
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
		see-also: [%kyoto.r] ]
]

do %kyoto.r

k: kyoto to-url first parse system/script/args none

oks: 0 kos: 0
ok: func [ ok ] [ either ok [oks: add oks 1][kos: add kos: 1] ]
is: func [ test expect ] [ ok equal? test expect ]

k/set "test" "tokyo"
is k/get "test" "tokyo"

print reform [ "ok:" oks "^\ko:" kos ]
