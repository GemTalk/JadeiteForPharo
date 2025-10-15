Class {
	#name : 'RowanAllClassCategoryService',
	#superclass : 'RowanClassCategoryService',
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'instance creation' }
RowanAllClassCategoryService class >> allClassCategory [

	| inst |
	inst := self new
		        name: 'All';
		        substringIndex: 0.
	^ inst
]

{ #category : 'accessing' }
RowanAllClassCategoryService >> classDefinitionTemplateString [

	^ String new
]

{ #category : 'accessing' }
RowanAllClassCategoryService >> data [

	^ String new
]

{ #category : 'displaying' }
RowanAllClassCategoryService >> displayString [

	^ 'All'
]

{ #category : 'accessing' }
RowanAllClassCategoryService >> firstSubstringsToIndex [

	^'*'
]

{ #category : 'accessing' }
RowanAllClassCategoryService >> tabLabel [

	^ 'All Class Categories'
]
