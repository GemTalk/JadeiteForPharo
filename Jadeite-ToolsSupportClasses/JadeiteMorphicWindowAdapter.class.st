Class {
	#name : 'JadeiteMorphicWindowAdapter',
	#superclass : 'SpMorphicWindowAdapter',
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'factory' }
JadeiteMorphicWindowAdapter >> buildWidget [

	^ JadeiteWindow new
		model: model;
		isResizeable: self isResizable;
		in: [ :this | self subscribeToAnnouncements: this ];
		yourself
]
