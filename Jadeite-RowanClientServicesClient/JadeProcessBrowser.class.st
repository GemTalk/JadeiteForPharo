Class {
	#name : 'JadeProcessBrowser',
	#superclass : 'DolphinClass',
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'private' }
JadeProcessBrowser >> update [
	| string lines priorities |
	RowanServiceUpdater current inUpdateWhile: [string := gciSession serverPerform: #processes].
	lines := (string subStrings: Character lf) asOrderedCollection.
	priorities := lines removeFirst subStrings: Character tab.
	priorities := priorities collect: 
					[:each |
					| pieces |
					pieces := each subStrings: Character space.
					pieces first -> pieces last asNumber].
	priorities := priorities asSortedCollection: [:a :b | a value > b value].
	prioritiesPresenter model list: priorities.
	lines := lines collect: [:each | (each subStrings: Character tab) , #('?' '?')].
	processesPresenter model list: lines
]
