let s:rails_root_cache = {}

fun! railstestnav#Root(...)
  let input = a:0 ? a:1 : expand('%:p')

  if !has_key(s:rails_root_cache, input)
    DEBUG '(uncached) input:' input

    let dir = fnamemodify(input, ':h')
    let root = ''

    let start = ''
    while dir != '/' && dir != l:start
      let start = dir
      if !empty(filter(['app','spec','lib'], 'isdirectory(dir."/".v:val)'))
        let root = dir
        break
      end
      let dir = fnamemodify(dir, ':h')
    endw

    let s:rails_root_cache[input] = root
    DEBUG 'root:' root
  end

  return s:rails_root_cache[input]
endf

fun! railstestnav#App(...)
  let root = call('railstestnav#Root', a:000)
  for subdir in ['app', 'lib']
    let dir = root . '/' . subdir
    if isdirectory(dir)
      return dir
    end
  endfo
endf

fun! railstestnav#SpecBase(...)
  let spec = call('railstestnav#Root', a:000).'/spec'
  let app = call('railstestnav#App', a:000)
  let subdir = split(copy(app), '/')[-1]
  if subdir != 'spec' && isdirectory(spec.'/'.subdir)
    let spec .= '/'.subdir
  end
  return spec
endf

fun! railstestnav#Features(...)
  return call('railstestnav#Root', a:000).'/spec/features'
endf

if exists('g:railstestnav_debug') && g:railstestnav_debug
  com! -nargs=* DEBUG echo <args>
else
  com! -nargs=* DEBUG :
end

fun! railstestnav#Alternate(...)
  let input = a:0 ? a:1 : expand('%:p')
  let ext = fnamemodify(input, ':e')

  let app = railstestnav#App(input)
  let spec_base = railstestnav#SpecBase(input)
  let features = railstestnav#Features(input)
  let steps = features.'/steps'

  if stridx(input, features) >= 0
    if stridx(input, steps) >= 0
      let bases = [ steps, features ]
      let replacements = [ '_steps\.rb$', '.feature' ]
    else
      let bases = [ features, steps ]
      let replacements = [ '\.feature$', '_steps.rb' ]
    end
  elseif stridx(input, spec_base) >= 0
    let bases = [ spec_base, app ]
    let replacements = [ '\.haml\zs_spec\.rb$', '', '_spec\ze\.rb$', '' ]
  elseif stridx(input, app) >= 0
    let bases = [ app, spec_base ]
    let replacements = [ '\.haml\zs$', '_spec.rb', '\ze\.rb$', '_spec' ]
  else
    throw 'rtn-E000: no Alternate file for '.input
  end

  let [this_base, other_base] = bases

  let rel = strpart(input, 1+strlen(this_base))

  let parts = split(rel, '/')
  let base = remove(parts, -1)

  while !empty(replacements)
    let [from, to] = remove(replacements, 0, 1)
    let mod = substitute(copy(base), from, to, '')
    if mod != base
      break
    end
  endw

  return join([other_base] + parts + [mod], '/')
endf
