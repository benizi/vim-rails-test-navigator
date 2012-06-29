fun! s:ToggleTestFile()
  let alt = railstestnav#Alternate()

  let already_open = bufwinnr(fnamemodify(alt, ':p'))
  if already_open >= 0
    exe already_open.'winc w'
  else
    exe 'new '.fnameescape(alt)
  end
endf

fun! s:DefineCommands()
  com! T sil! call s:ToggleTestFile()
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
