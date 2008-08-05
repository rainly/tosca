require File.dirname(__FILE__) + '/../test_helper'

class ContractTest < Test::Unit::TestCase
  fixtures :contracts, :logiciels, :versions, :contracts_engagements, :engagements,
    :demandes, :components, :credits, :clients, :users, :contracts_users,
    :ingenieurs, :recipients

  def test_to_strings
    check_strings Contract, :ouverture_formatted, :cloture_formatted
  end

  def test_dates
    c = Contract.find 1
    # Schedule check
    assert c.heure_ouverture <= c.heure_fermeture
    c.heure_ouverture = -1
    assert !c.save
    c.heure_ouverture = 25
    assert !c.save
    c.heure_ouverture = 12
    c.heure_fermeture = 9
    assert !c.save
    c.heure_ouverture = 9
    c.heure_fermeture = 12
    assert c.save
  end

  def test_invervals
    c = Contract.find(:first)
    interval = c.interval
    assert_equal c.interval_in_seconds, interval * 1.hour
  end

  def test_logiciels
    Contract.find(:first).logiciels.each{ |l| assert l.is_a?(Logiciel)}
  end

  def test_demandes
    c = Contract.find :first
    c.demandes.each{ |d|
      assert d.is_a?(Demande)
      assert_equal d.contract_id, c.id
    }
  end

  def test_typedemandes
    Contract.find(:all).each do |c|
      c.typedemandes.each{ |td| assert_kind_of Typedemande, td }
    end
  end

  def test_credit?
    Contract.find(:first).credit?
  end

  def test_find_recipients_select
    recipients = Contract.find(:first).find_recipients_select
    assert !recipients.empty?
  end

  def test_scope
    Contract.set_scope([Contract.find(:first).id])
    Contract.find(:all)
    Contract.remove_scope
  end


  def test_engineer_users
    Contract.find(:all).each do |c|
      c.engineer_users.each { |i|
        assert_kind_of User, i
        assert i.ingenieur
      }
    end
  end

  def test_engineers
    Contract.find(:all).each do |c|
      c.engineers.each { |i|
        assert_kind_of User, i
        assert i.ingenieur
      }
    end
  end

end
