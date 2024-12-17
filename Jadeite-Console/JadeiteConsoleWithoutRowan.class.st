Class {
	#name : 'JadeiteConsoleWithoutRowan',
	#superclass : 'JadeiteConsole',
	#category : 'Jadeite-Console',
	#package : 'Jadeite-Console'
}

{ #category : 'actions' }
JadeiteConsoleWithoutRowan >> basicUnloadProjects: projectNames onCompletion: completionBlock [

	"nothing to do when rowan not available"
]

{ #category : 'initialization' }
JadeiteConsoleWithoutRowan >> initializeProjectListPresenter: tabs [

	projectListPresenter := JadeiteTablePresenter new
]

{ #category : 'registration' }
JadeiteConsoleWithoutRowan >> registerPresentersForUpdates [
]
