Class {
	#name : 'JadeiteDiffAdapter',
	#superclass : 'SpMorphicDiffAdapter',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'factory' }
JadeiteDiffAdapter >> buildWidget [

	^ JadeiteDiffMorph new
		  on: self;
		  from: self leftText
		  to: self rightText
		  contextClass: self contextClass;
		  hResizing: #spaceFill;
		  vResizing: #spaceFill;
		  setBalloonText: self help;
		  showOptions: self showOptions;
		  leftLabel: self leftLabel rightLabel: self rightLabel;
		  showOnlyDestination: self showOnlyDestination;
		  yourself
]
