Extension { #name : 'JadeiteLoginShell' }

{ #category : '*Jadeite-Tests' }
JadeiteLoginShell >> loginWithoutErrorHandling [
	"for testing"

	| session |
	self updateModel.
	session := self model login.
	self postShellLogin: session
]
