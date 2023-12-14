Class {
	#name : 'BaselineOfJadeiteForPharo',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfJadeiteForPharo'
}

{ #category : 'baselines' }
BaselineOfJadeiteForPharo >> baseline: spec [

	<baseline>
	spec for: #pharo do: [
		spec
			postLoadDoIt: #postload:package:;
			package: 'Jadeite-Applications';
			package: 'Jadeite-Traits'
			with: [ spec requires: 'Jadeite-Applications' ];
			package: 'Jadeite-TextPanes'
			with: [ spec requires: 'Jadeite-Traits' ];
			package: 'Jadeite-SupportClasses'
			with: [
				spec requires: #( 'Jadeite-TextPanes' 'RemoteServiceReplication' ) ];
			package: 'Jadeite-BaseExtensions'
			with: [ spec requires: 'Jadeite-SupportClasses' ];
			package: 'Jadeite-RowanClientServicesClient'
			with: [ spec requires: 'Jadeite-SupportClasses' ];
			package: 'Jadeite-PortedClasses'
			with: [ spec requires: 'Jadeite-RowanClientServicesClient' ];
			package: 'Jadeite-Browser'
			with: [ spec requires: 'Jadeite-PortedClasses' ];
			package: 'Jadeite-Console'
			with: [ spec requires: 'Jadeite-Browser' ];
			package: 'Jadeite-Inspector'
			with: [ spec requires: 'Jadeite-Console' ];
			package: 'Jadeite-Logger'
			with: [ spec requires: 'Jadeite-Inspector' ];
			package: 'Jadeite-MethodBrowser'
			with: [ spec requires: 'Jadeite-Logger' ];
			package: 'Jadeite-SUnitBrowser'
			with: [ spec requires: 'Jadeite-MethodBrowser' ];
			package: 'Jadeite-FileDialog'
			with: [ spec requires: 'Jadeite-SUnitBrowser' ];
			package: 'Jadeite-Changes'
			with: [ spec requires: 'Jadeite-FileDialog' ];
			package: 'Jadeite-Debugger'
			with: [ spec requires: 'Jadeite-Changes' ];
			package: 'Jadeite-Connection'
			with: [ spec requires: 'Jadeite-Debugger' ];
			package: 'Jadeite-Tests'
			with: [ spec requires: 'Jadeite-Connection' ].
		spec
			baseline: 'RemoteServiceReplication'
			with: [ spec repository: self rsrUrl ].
		spec
			baseline: 'PharoGemStoneFFI'
			with: [ spec repository: self pharoGemStoneFFIUrl ] ]
]

{ #category : 'baselines' }
BaselineOfJadeiteForPharo >> githubUrlForGemTalkProject: projectName [

	^ 'github://GemTalk/' , projectName , ':main'
]

{ #category : 'baselines' }
BaselineOfJadeiteForPharo >> pharoGemStoneFFIUrl [

	^ self urlForProject: 'PharoGemStoneFFI'
]

{ #category : 'actions' }
BaselineOfJadeiteForPharo >> postload: loader package: packageSpec [
	"assume JadeiteForPharo is loaded from a local directory"
	
	| description path  writeStream htmlReference cssReference html css|
	description := packageSpec repositoriesSpec list first spec description.
	path := description withoutPrefix:   'gitlocal://'.
	writeStream := WriteStream on: String new.
	html := 'jadeitehelp.html'.
	css := 'jadeitehelp.css'.
	writeStream nextPutAll: path;  
	 nextPut: $/;
	 nextPutAll: html.
	htmlReference := FileReference fileSystem: FileSystem disk path: writeStream contents asPath. 
	htmlReference copyTo: (FileReference fileSystem: FileSystem disk path: html asPath).
	writeStream := WriteStream on: String new.
	writeStream nextPutAll: path;  
	 nextPut: $/;
	 nextPutAll: css.
	cssReference := FileReference fileSystem: FileSystem disk path: writeStream contents asPath. 
	cssReference copyTo: (FileReference fileSystem: FileSystem disk path: css asPath).
	
]

{ #category : 'baselines' }
BaselineOfJadeiteForPharo >> rsrUrl [

	^ self urlForProject: 'RemoteServiceReplication'
]

{ #category : 'baselines' }
BaselineOfJadeiteForPharo >> urlForProject: projectName [

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
