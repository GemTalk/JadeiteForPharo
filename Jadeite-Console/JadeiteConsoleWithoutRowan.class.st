Class {
	#name : 'JadeiteConsoleWithoutRowan',
	#superclass : 'JadeiteConsole',
	#category : 'Jadeite-Console',
	#package : 'Jadeite-Console'
}

{ #category : 'initialization' }
JadeiteConsoleWithoutRowan >> initializeProjectListPresenter: tabs [

	projectListPresenter := JadeiteTablePresenter new
]

{ #category : 'registration' }
JadeiteConsoleWithoutRowan >> registerPresentersForUpdates [
]
