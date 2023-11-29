Class {
	#name : 'JadeiteTableAdapter',
	#superclass : 'SpMorphicTableAdapter',
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'factory' }
JadeiteTableAdapter >> buildWidget [

	widget := JadeiteTableMorph new  "<<<Jadeite change here"
		selectionConfirmationBlock: [ self presenter okToDiscardMethodChanges ]; "<<<Jadeite change here"
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		intercellSpacing: self class intercellSpacing;
		dragEnabled: self dragEnabled;
		dropEnabled: self dropEnabled;
		yourself.

	self addModelTo: widget.

	^ widget
]
