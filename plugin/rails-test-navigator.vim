fun! s:ToggleTestFile(force)
  let alt = railstestnav#Alternate()

  let already_open = bufwinnr(fnamemodify(alt, ':p'))
  if already_open >= 0 && !strlen(a:force)
    exe already_open.'winc w'
  else
    exe 'new '.fnameescape(alt)
  end
endf

fun! s:DefineCommands()
  com! -bang T sil! call s:ToggleTestFile('<bang>')
endf

fun! s:SetupNewBuffer()
  call s:SetupFiletype()
endf

fun! s:SetupFiletype()
  call s:DefineCommands()
endf

aug RailsTestNavigator
  au! BufReadPost,BufNew * call s:SetupNewBuffer()
  au! Filetype * call s:SetupFiletype()
aug END
