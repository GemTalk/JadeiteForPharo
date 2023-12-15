"
A landing spot for code that is used everywhere across models and presenters. 
Hopefully, with good design, behavior in this class will be limited.
"
Trait {
	#name : 'JadeiteUtilityTrait',
	#category : 'Jadeite-Traits'
}

{ #category : 'updates' }
JadeiteUtilityTrait >> sortedProjectsFrom: theProjects [

	^ theProjects asSortedCollection: [ :x :y |
		  x name asLowercase < y name asLowercase ]
]
