DAMAGE_COMPONENTS = [9, 3, 1]

class SCV
  attr_accessor :hp

  def initialize(hp)
    @hp = hp
  end

  def attack_change(remaining_hp=hp, acc={})
    return acc if (DAMAGE_COMPONENTS - acc.keys).empty?

    damage_per_hit = (DAMAGE_COMPONENTS - acc.keys).first
    hits = remaining_hp / damage_per_hit

    attack_change(
      remaining_hp - damage_per_hit * hits,
      acc.merge(damage_per_hit => hits),
    )
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

    index = nil

    scvs_with_index
      .select { |scv, i| allow_wasting_damage || can_shoot_cleanly?(damage, unavailable_indices, i) }
      .each do |scv, i|
        next if unavailable_indices.include?(i)
        index ||= i
        if (scv.attack_change.values.sum > scvs[index].attack_change.values.sum) ||
          (scv.attack_change.values.sum == scvs[index].attack_change.values.sum && scv.hp >= scvs[index].hp)
          index = i
        end
      end

    return index
  end

  def shoot
    shot_indices = []
    DAMAGE_COMPONENTS.each do |damage_component|
      index = index_to_shoot(damage_component, shot_indices)
      shot_indices << index
      hps[index] = [hps[index] - damage_component, 0].max
    end
  end

  def min_attacks_to_kill
    shots = 0
    while hps.any? { |hp| hp > 0}
      shoot
      shots += 1
    end
    shots
  end
end