Extension { #name : 'Time' }

{ #category : '*Jadeite-BaseExtensions' }
Time >> jadeitePrint24: hr24 showSeconds: showSeconds on: aStream [
	"derived from #print24:showSeconds:on:
	print without :'s for use in windows log files"

	| h m s |
	h := self hour. m := self minute. s := self second.
	hr24
		ifTrue: [
			h < 10 ifTrue: [ aStream nextPut: $0 ].
			h printOn: aStream ]
		ifFalse: [
			h > 12
				ifTrue: [ h - 12 printOn: aStream ]
				ifFalse: [
					h < 1
						ifTrue: [ 12 printOn: aStream ]
						ifFalse: [ h printOn: aStream ] ] ].
	m printOn: aStream.
	showSeconds
		ifTrue: [
			s printOn: aStream.
			nanos = 0
				ifFalse: [ | n len |
					n := nanos. len := 9.
					[ n \\ 10 = 0 ] whileTrue: [ n := n / 10. len := len - 1 ].
					aStream nextPut: $..
					n printOn: aStream base: 10 length: len padded: true ] ].
	hr24 ifFalse: [ aStream nextPutAll: (h < 12 ifTrue: [ ' am' ] ifFalse: [ ' pm' ]) ]
]
