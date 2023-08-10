Class {
	#name : 'BaselineOfJadeite',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfJadeite'
}

{ #category : 'baselines' }
BaselineOfJadeite >> baseline: spec [

	<baseline>
	spec for: #pharo do: [
		spec
			postLoadDoIt: #postload:package:;
			package: 'JadeiteApplications';
			package: 'JadeiteToolsTraits'
			with: [ spec requires: 'JadeiteApplications' ];
			package: 'JadeiteTextPanes'
			with: [ spec requires: 'JadeiteToolsTraits' ];
			package: 'JadeiteToolsSupportClasses'
			with: [
				spec requires: #( 'JadeiteTextPanes' 'RemoteServiceReplication' ) ];
			package: 'RowanClientServicesClient'
			with: [ spec requires: 'JadeiteToolsSupportClasses' ];
			package: 'JadeitePortedClasses'
			with: [ spec requires: 'RowanClientServicesClient' ];
			package: 'JadeiteBrowser'
			with: [ spec requires: 'JadeitePortedClasses' ];
			package: 'JadeiteConsole'
			with: [ spec requires: 'JadeiteBrowser' ];
			package: 'JadeiteInspector'
			with: [ spec requires: 'JadeiteConsole' ];
			package: 'JadeiteLogger'
			with: [ spec requires: 'JadeiteInspector' ];
			package: 'JadeiteMethodBrowser'
			with: [ spec requires: 'JadeiteLogger' ];
			package: 'JadeiteSUnitBrowser'
			with: [ spec requires: 'JadeiteMethodBrowser' ];
			package: 'JadeiteFileDialog'
			with: [ spec requires: 'JadeiteSUnitBrowser' ];
			package: 'JadeiteChanges'
			with: [ spec requires: 'JadeiteFileDialog' ];
			package: 'JadeiteDebugger'
			with: [ spec requires: 'JadeiteChanges' ];
			package: 'JadeiteConnection'
			with: [ spec requires: 'JadeiteDebugger' ];
			package: 'JadeiteTests'
			with: [ spec requires: 'JadeiteConnection' ].
		spec
			baseline: 'RemoteServiceReplication'
			with: [ spec repository: self rsrUrl ].
		spec
			baseline: 'PharoGemStoneFFI'
			with: [ spec repository: self pharoGemStoneFFIUrl ] ]
]

{ #category : 'baselines' }
BaselineOfJadeite >> githubUrlForGemTalkProject: projectName [

	^ 'github://GemTalk/' , projectName , ':main'
]

{ #category : 'baselines' }
BaselineOfJadeite >> pharoGemStoneFFIUrl [

	^ self urlForProject: 'PharoGemStoneFFI'
]

{ #category : 'actions' }
BaselineOfJadeite >> postload: loader package: packageSpec [
]

{ #category : 'baselines' }
BaselineOfJadeite >> rsrUrl [

	^ self urlForProject: 'RemoteServiceReplication'
]

{ #category : 'baselines' }
BaselineOfJadeite >> urlForProject: projectName [

	| projectsHome path |
	projectsHome := OSEnvironment current
		                at: 'ROWAN_PROJECTS_HOME'
		                ifAbsent: [ 
		                ^ self githubUrlForGemTalkProject: projectName ].
	path := Path / projectsHome / projectName / 'src'.
	^ path asFileReference exists
		ifFalse: [ self githubUrlForGemTalkProject: projectName ]
		ifTrue: [ 'gitlocal://' , path pathString ]
]
