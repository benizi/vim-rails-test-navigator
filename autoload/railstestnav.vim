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
      if isdirectory(dir.'/app')
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

fun! s:Contains(list, thing)
  return len(filter(copy(a:list), 'v:val == a:thing'))
endf

fun! s:Upto(list, thing)
  let ret = []
  for item in a:list
    call add(ret, item)
    if item == a:thing
      break
    end
  endfo
  return ret
endf

fun! s:Path(parts)
  return join(copy(a:parts), '/')
endf

fun! s:PathUpto(list, root, thing)
  return s:Path([a:root] + s:Upto(a:list, a:thing))
endf

if exists('g:railstestnav_debug') && g:railstestnav_debug
  com! -nargs=* DEBUG echo <args>
else
  com! -nargs=* DEBUG :
end

fun! railstestnav#Alternate(...)
  let input = a:0 ? a:1 : expand('%:p')
  let ext = expand('%:e')

  let root = railstestnav#Root(input)
  let rel = strpart(input, 1+strlen(root))

  let path = split(rel, '/')
  let top = path[0]
  let base = path[-1]

  if top == 'spec'
    DEBUG 'in tests'
    if s:Contains(path, 'features')
      DEBUG 'in features'
      let features = s:PathUpto(path, root, 'features')
      if s:Contains(path, 'steps')
        DEBUG 'in steps : go to features'
        let mod = substitute(base, '_steps\.rb$', '.feature', '')
        if base != mod
          return s:Path([features, mod])
        end
      else
        DEBUG 'go to steps'
        let mod = substitute(base, '\.feature$', '_steps.rb', '')
        if base != mod
          return s:Path([features, 'steps', mod])
        end
      end
    else
      DEBUG 'go to app'
      let mod = substitute(base, '_spec\ze\.rb$', '', '')
      if base != mod
        return s:Path(['app'] + path[1:-2] + [ mod ])
      end
    end
  elseif top == 'app'
    DEBUG 'in app : go to tests'
    let mod = substitute(base, '\ze\.rb$', '_spec', '')
    if base != mod
      return s:Path(['spec'] + path[1:-2] + [ mod ])
    end
  end

  throw 'rtn-E000: no Alternate file for '.input
endf
