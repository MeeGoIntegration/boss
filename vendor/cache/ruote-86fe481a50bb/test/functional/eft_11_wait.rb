
#
# testing ruote
#
# Thu Jun 18 11:03:45 JST 2009
#

require File.expand_path('../base', __FILE__)


class EftWaitTest < Test::Unit::TestCase
  include FunctionalBase

  def test_wait_for

    pdef =
      Ruote.define do
        alpha
        wait :for => '2s'
        alpha
        echo 'done.'
      end

    @dashboard.context.stash[:ts] = []

    @dashboard.register_participant(:alpha) { stash[:ts] << Time.now }

    assert_trace 'done.', pdef

    d = (
      @dashboard.context.stash[:ts][1].sec - @dashboard.context.stash[:ts][0].sec
    ) % 60

    deltas = [ 2, 3, 4 ]
    #deltas << 4 if @dashboard.storage.class.name.match(/^Ruote::Couch::/)

    assert(
      deltas.include?(d),
      "delta is #{d}, which isn't in #{deltas.inspect}")
  end

  def test_cancel_wait

    pdef =
      Ruote.define do
        echo 'a'
        wait :for => '3d'
        echo 'b'
      end

    wfid = @dashboard.launch(pdef)

    wait_for(4)

    @dashboard.cancel_process(wfid)

    wait_for(wfid)

    assert_equal 'a', @tracer.to_s
    assert_equal 0, @dashboard.storage.get_many('schedules').size
  end

  def test_wait_until

    @dashboard.context.stash[:ts] = []

    @dashboard.register_participant(:alpha) { stash[:ts] << Time.now }

    pdef =
      Ruote.define do
        alpha
        wait :until => (Time.now + 2.0).to_s
        alpha
        echo 'done.'
      end

    assert_trace 'done.', pdef

    ts0 = @dashboard.context.stash[:ts][0]
    ts1 = @dashboard.context.stash[:ts][1]

    assert(ts1 - ts0 > 1.0, "#{ts1 - ts0} should be > 1.0")
  end

  def test_wait_until_now

    pdef =
      Ruote.define do
        echo 'a'
        wait Time.now
        echo 'b'
      end

    assert_trace %w[ a b ], pdef
  end

  # https://github.com/jmettraux/ruote/issues/73
  #
  def test_wait_until_tz_string

    pdef =
      Ruote.define do
        wait :until => '1913-02-08T17:36:10Z'
      end

    wfid = @dashboard.launch(pdef)
    r = @dashboard.wait_for(wfid)

    assert_equal 'terminated', r['action']
  end
end

