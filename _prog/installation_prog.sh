

_vector_prog() {
	
	true
	
	# ATTENTION: Currently not scripted. Go to "$scriptLib"/vector , run the '../../_BOM_designer_geometry' function, and compare with results stored by git repository.
	
}



_test_prog() {
	
	_vector_prog
	
}


_setup_prog() {
	mkdir -p "$HOME"/.local/share/katepart5/syntax
	cp "$scriptLib"/kwrite_syntax_highlighting/* "$HOME"/.local/share/katepart5/syntax/
	
	[[ ! -e "$HOME"/.local/share/katepart5/syntax/lbom.xml ]] && echo 'warn: missing: ~/.local/share/katepart5/syntax/'
	
	return 0
}
