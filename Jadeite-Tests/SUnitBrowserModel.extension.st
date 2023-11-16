Extension { #name : 'SUnitBrowserModel' }

{ #category : '*Jadeite-Tests' }
SUnitBrowserModel >> debugIndividualTestsWithResources: tests [
	| resources |
	#GemTalkAdded.	"forgotten by oa"
	resources := self resourcesFor: tests.
	
	[self
		startResources: resources;
		debugIndividualTests: tests]
			ensure: [self stopResources: resources]
]
