Class {
	#name : 'JadeiteBrowserMonticello',
	#superclass : 'JadeiteBrowserWithoutRowan',
	#category : 'Jadeite-Browser',
	#package : 'Jadeite-Browser'
}

{ #category : 'accessing' }
JadeiteBrowserMonticello class >> browserPresenterClass [

	^ JadeiteBrowserPresenterMonticello
]

{ #category : 'constants' }
JadeiteBrowserMonticello >> shellName [
	^'System Monticello Browser'
]
