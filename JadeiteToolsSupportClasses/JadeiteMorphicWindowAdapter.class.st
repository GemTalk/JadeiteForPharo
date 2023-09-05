Class {
	#name : 'JadeiteMorphicWindowAdapter',
	#superclass : 'SpMorphicWindowAdapter',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'factory' }
JadeiteMorphicWindowAdapter >> buildWidget [

	^ JadeiteWindow new
		model: model;
		isResizeable: self isResizable;
		in: [ :this | self subscribeToAnnouncements: this ];
		yourself
]
