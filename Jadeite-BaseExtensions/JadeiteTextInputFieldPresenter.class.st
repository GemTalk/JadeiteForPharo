Class {
	#name : 'JadeiteTextInputFieldPresenter',
	#superclass : 'SpTextInputFieldPresenter',
	#category : 'Jadeite-BaseExtensions',
	#package : 'Jadeite-BaseExtensions'
}

{ #category : 'specs' }
JadeiteTextInputFieldPresenter class >> adapterName [

	^ #JadeiteTextInputFieldAdapter
]

{ #category : 'api' }
JadeiteTextInputFieldPresenter >> contextMenu [

	^ SpMenuPresenter new addGroup: [ :group |
		  group addItem: [ :item |
			  item
				  name: 'Cancel';
				  action: [ self adapter widget cancel ] ] ]
]
