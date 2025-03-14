Class {
	#name : 'JadeiteSpApplication',
	#superclass : 'SpApplication',
	#category : 'Jadeite-BaseExtensions',
	#package : 'Jadeite-BaseExtensions'
}

{ #category : 'adding' }
JadeiteSpApplication >> addBorderStyleTo: windowPresenter presenter: inst [

	inst addWindowBorderStyle: 'jadeiteWindowBorderStyle'.
	^ windowPresenter window extent: windowPresenter initialExtent
]

{ #category : 'showing' }
JadeiteSpApplication >> defaultModalWindowPresenterClass [
		
	^ JadeiteModalWindowPresenter
]
