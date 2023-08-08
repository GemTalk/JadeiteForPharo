Extension { #name : 'JadeiteLoginShell' }

{ #category : '*JadeiteTests' }
JadeiteLoginShell >> loginWithoutErrorHandling [
	"for testing"

	| session |
	self updateModel.
	session := self model login.
	self postShellLogin: session
]
