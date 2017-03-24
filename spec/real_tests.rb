

# This script is able to run REAL tests against a REAL Wavefront
# account. It will add, change, and delete data. Do not do it unless you
# are sure you want to do it and you understand what it will do! You need a
# config file with a stanza called "cli-test", which has valid WF credentials.
#
run_real = true

if run_real
  REAL_CF = Pathname.new(ENV['HOME']) + '.wavefront'
  LIVE_OPTS = "-c #{REAL_CF} -P cli-test"

  if ! REAL_CF.exist?
    puts "cannot run real tests, no config at #{REAL_CF}"
    run_real = false
  elsif ! IO.read(REAL_CF).split("\n").include?('[cli-test]')
    puts "cannot run real tests, no 'cli-test' stanza in #{REAL_CF}"
    run_real = false
  end
end

if run_real
  keys = %w(name created severity condition alertStates)

  it 'fetches and correctly formats alerts from config file and CLI options' do
    o = wf("alerts #{LIVE_OPTS} -f human all")
    expect(o.status).to eq(0)
    expect(o.stderr).to be_empty
    expect(o.stdout_a.first).to start_with('name ')
    keys.each { |key| expect(o.stdout).to start_with(key + ' ') }
  end

  it 'fetches and correctly formats alerts from config file' do
    o = wf("alerts #{LIVE_OPTS} all")
    expect(o.status).to eq(0)
    expect(o.stderr).to be_empty
    r = JSON.parse(o.stdout)
    expect(r).to be_instance_of(Array)
    expect(r.first).to be_instance_of(Hash)
    keys.each { |key| expect(r.first.keys).to include(key) }
  end
end


  if run_real
    it 'gets an empty JSON payload for a silly request' do
      o = wf("ts #{LIVE_OPTS} -f raw -m 'ts(better.not.exist)'")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      r = JSON.parse(o.stdout)
      expect(r['query']).to eq('ts(better.not.exist)')
      expect(r['warnings']).to eq('No metrics matching: [better.not.exist]')
    end

    it 'gets an empty human payload for a silly request' do
      o = wf("ts #{LIVE_OPTS} -f human -m 'ts(better.not.exist)'")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout).to be_empty
    end
  end
