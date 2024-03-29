Extension { #name : 'RubTextSegmentMorph' }

{ #category : '*Jadeite-BaseExtensions' }
RubTextSegmentMorph >> whenExtentChanged: anAnnouncement [

	[ self computeVertices ]
		on: Error
		do: [ :ex |  ] "Jadeite override - try to stop Red X's. This is horrible. Can't just test for owner=nil like so much other Morphic code because the owner might get nilled later."
]
