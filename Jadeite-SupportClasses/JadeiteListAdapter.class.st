Class {
	#name : 'JadeiteListAdapter',
	#superclass : 'SpMorphicListAdapter',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'factory' }
JadeiteListAdapter >> buildWidget [

	| datasource |
	datasource := SpMorphicListDataSource new.
	datasource model: self model.
	widget := JadeiteTableMorph new
		          selectionConfirmationBlock: [
			          self presenter canDiscardEdits ];
		          "<<<Jadeite change here"dataSource: datasource;
		          hideColumnHeaders;
		          enableSearch;
		          beResizable;
		          columns: { self newListColumn };
		          setMultipleSelection: self model isMultipleSelection;
		          dragEnabled: self dragEnabled;
		          dropEnabled: self dropEnabled;
		          setBalloonText: self help;
		          hResizing: #spaceFill;
		          vResizing: #spaceFill;
		          onAnnouncement: FTSelectionChanged
		          send: #selectionChanged:
		          to: self;
		          onAnnouncement: FTStrongSelectionChanged
		          send: #strongSelectionChanged:
		          to: self;
		          yourself. "<<<Jadeite change here"

	self presenter whenModelChangedDo: [ widget refresh ].
	self presenter whenSelectionChangedDo: [ self refreshWidgetSelection ].
	self presenter whenSearchEnabledChangedDo: [ self updateSearch ].
	self refreshWidgetHeaderTitle.
	self refreshWidgetSelection.
	"self presenter whenItemFilterBlockChangedDo: [ :block |
		self updateItemFilterBlockWith: block ].
	self updateItemFilterBlockWith: self itemFilter."

	self configureScrolling.
	widget
		bindKeyCombination: Character space
		toAction: [ self model clickOnSelectedItem ].

	^ widget
]
