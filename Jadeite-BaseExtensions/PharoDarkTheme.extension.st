Extension { #name : 'PharoDarkTheme' }

{ #category : '*Jadeite-BaseExtensions' }
PharoDarkTheme >> jadeiteBackgroundColor [

	^self backgroundColor
]

{ #category : '*Jadeite-BaseExtensions' }
PharoDarkTheme >> jadeiteBorderColor [

	^Color purple
]

{ #category : '*Jadeite-BaseExtensions' }
PharoDarkTheme >> jadeiteBorderWidth [

	^3
]

{ #category : '*Jadeite-BaseExtensions' }
PharoDarkTheme >> jadeiteChangedTextBackgroundColor [

	^Color veryDarkGray
]

{ #category : '*Jadeite-BaseExtensions' }
PharoDarkTheme >> jadeiteColorAdjustment [

	^ -0.40
]

{ #category : '*Jadeite-BaseExtensions' }
PharoDarkTheme >> jadeiteColorErrors [

	^super jadeiteColorErrors adjustBrightness: self jadeiteColorAdjustment
]

{ #category : '*Jadeite-BaseExtensions' }
PharoDarkTheme >> jadeiteColorFailures [

	^ super jadeiteColorFailures adjustBrightness:
		  self jadeiteColorAdjustment
]

{ #category : '*Jadeite-BaseExtensions' }
PharoDarkTheme >> jadeiteColorPass [

	^ super jadeiteColorPass adjustBrightness:
		  self jadeiteColorAdjustment
]
