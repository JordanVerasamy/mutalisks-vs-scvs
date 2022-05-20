class SCV
  attr_accessor :hp

  def initialize(hp)
    @hp = hp
  end

  def attack_change
    {
      9 => hp / 9,
      3 => (hp % 9) / 3,
      1 => hp % 3,
    }.compact
  end
end

class SCVs
  attr_accessor :hps

  def initialize(hps)
    @hps = hps
  end

  def scvs
    hps.map { |hp| SCV.new(hp) }
  end

  def scvs_with_index
    scvs.zip(0..scvs.length-1)
  end

  def can_shoot_cleanly?(damage, unavailable_indices, i)
    scvs[i].attack_change[damage] > 0 && !unavailable_indices.include?(i)
  end

  def index_to_shoot(damage, unavailable_indices)
    allow_wasting_damage = scvs_with_index.none? do |scv, i|
      can_shoot_cleanly?(damage, unavailable_indices, i)
    end

    index = 0

    scvs_with_index
      .select { |scv, i| allow_wasting_damage || can_shoot_cleanly?(damage, unavailable_indices, i) }
      .each do |scv, i|
        if (scv.attack_change.values.sum > scvs[index].attack_change.values.sum) ||
          (scv.attack_change.values.sum == scvs[index].attack_change.values.sum && scv.hp >= scvs[index].hp)
          index = i
        end
      end

    return index
  end

  def shoot
    shot_indices = []
    [9, 3, 1].each do |damage_component|
      index = index_to_shoot(damage_component, shot_indices)
      shot_indices << index
      hps[index] = [hps[index] - damage_component, 0].max
    end

    return hps.any? { |hp| hp > 0}
  end

  def min_attacks_to_kill
    shots = 1
    while shoot
      shots += 1
    end
    shots
  end
end