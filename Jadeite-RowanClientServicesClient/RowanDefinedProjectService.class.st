Class {
	#name : 'RowanDefinedProjectService',
	#superclass : 'RowanProjectService',
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'public' }
RowanDefinedProjectService >> isDefinedProject [

	^true
]

{ #category : 'public' }
RowanDefinedProjectService >> newProject: presenter [
	presenter list detect: [:projectService | projectService = self]
		ifNone: 
			[presenter list add: self.
			presenter view invalidate]
]
