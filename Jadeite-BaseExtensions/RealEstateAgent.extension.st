Extension { #name : 'RealEstateAgent' }

{ #category : '*Jadeite-BaseExtensions' }
RealEstateAgent class >> cursorPointFor: aView initialExtent: initialExtent world: aWorld [

	| position allowedArea |
	allowedArea := self maximumUsableAreaInWorld: aWorld.
	position := aWorld firstHand cursorPoint. 
	^ (position extent: initialExtent)
		translatedAndSquishedToBeWithin: allowedArea
]
