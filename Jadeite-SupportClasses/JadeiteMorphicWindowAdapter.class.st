Class {
	#name : 'JadeiteMorphicWindowAdapter',
	#superclass : 'SpMorphicWindowAdapter',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'factory' }
JadeiteMorphicWindowAdapter >> buildWidget [

	^ JadeiteWindow new
		model: model;
		isResizeable: self isResizable;
		in: [ :this | self subscribeToAnnouncements: this ];
		yourself
]

{ #category : 'testing' }
JadeiteMorphicWindowAdapter >> canDiscardEdits [
	"the presenter is asked first. If it says 'no' then I shouldn't override that. 
	See SpWindowPresenter>>okToChange"
	
	^false 
]
