require File.expand_path('../../sigdump', __FILE__)

signal = ENV['SIGDUMP_SIGNAL'] || 'SIGCONT'
path = ENV['SIGDUMP_PATH'] || ''

Sigdump.setup(signal, path)

