class SCV
  attr_accessor :hp

  def initialize(hp)
    @hp = hp
  end

  def attack_change
    _9_damage = hp / 9
    _3_damage = (hp % 9) / 3
    _1_damage = hp % 3

    {
      9 => _9_damage,
      3 => _3_damage,
      1 => _1_damage,
    }.compact
  end
end

class SCVs
  attr_accessor :hps

  def initialize(hps)
    @hps = hps
  end

  def scvs
    hps.map do |hp|
      SCV.new(hp)
    end
  end

  def index_of_scv_with_most_shots_remaining(unavailable_indices)
    index = 0

    scvs.each_with_index do |scv, i|
      next if unavailable_indices.include?(i)

      if scv.attack_change.values.sum > scvs[index].attack_change.values.sum
        index = i
      elsif scv.attack_change.values.sum == scvs[index].attack_change.values.sum
        # tiebreak by remaining hp
        if scv.hp >= scvs[index].hp
          index = i
        end
      end
    end
    return index
  end

  def index_of_scv_that_can_take_damage_cleanly_with_most_shots_remaining(damage, unavailable_indices)
    index = 0

    scvs
      .zip(0..scvs.length-1)
      .select { |scv, index| scv.attack_change.key?(damage) && scv.attack_change[damage] > 0 }
      .each do |scv, i|
      next if unavailable_indices.include?(i)

      if scv.attack_change.values.sum > scvs[index].attack_change.values.sum
        index = i
      elsif scv.attack_change.values.sum == scvs[index].attack_change.values.sum
        # tiebreak by remaining hp
        if scv.hp >= scvs[index].hp
          index = i
        end
      end
    end
    return index
  end

  def index_to_shoot_with(damage, unavailable_indices)
    scvs.each_with_index do |scv, i|
      next if unavailable_indices.include?(i)

      if scv.attack_change.key?(damage) && scv.attack_change[damage] > 0
        return index_of_scv_that_can_take_damage_cleanly_with_most_shots_remaining(damage, unavailable_indices)
      end
    end

    index_of_scv_with_most_shots_remaining(unavailable_indices)
  end

  def shoot
    shot_indices = []
    [9, 3, 1].each do |damage_component|
      index = index_to_shoot_with(damage_component, shot_indices)
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