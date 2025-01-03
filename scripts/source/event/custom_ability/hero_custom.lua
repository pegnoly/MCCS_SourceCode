CustomAbility.Hero = {}

CustomAbility.Hero.is_loaded = nil

CustomAbility.Hero.EnabledForHero = {}

CustomAbility.Hero.AbilitiesByHero = {}

CustomAbility.Hero.DialogPredefAnswers = {}

CustomAbility.Hero.Callbacks = {}

CustomAbility.Hero.MainDialog =
{
  state = 1,
  path = '/Text/CustomAbility/Main/',
  icon = '/Textures/Interface/Cartographer/Face_Texture.xdb#xpointer(/Texture)',
  title = 'hero_title',
  select_text = 'hero_select',
  
  perform_func =
  function(player, curr_state, answer, next_state)
    startThread(CustomAbility.Hero.Callbacks[next_state], Dialog.GetActiveHeroForPlayer(player), player)
    return 0
  end,
  
  options = {},
  
  Reset =
  function(player)
    --print("Reseting current dialog...")
    for i, option in Dialog.GetActiveDialogForPlayer(player).options do
      option = nil
    end
    --print("Success")
    Dialog.GetActiveDialogForPlayer(player).options[1] = {[0] = 'Text/CustomAbility/Main/hero_main.txt';}
    --print("Options reseted...")
  end,
  
  Open =
  function(player)
    local hero = Dialog.GetActiveHeroForPlayer(player)
    --print("Opening hero custom dialog...")
    Dialog.Reset(player)
    --print("Reseted correctly")
    local n = 1
    --print("Checking predef answers...")
    for answer, info in CustomAbility.Hero.DialogPredefAnswers do
      --print("Ability info: ", info)
      if CustomAbility.Hero.AbilitiesByHero[hero][answer] then
         --print("Hero has this ability")
         Dialog.SetPredefAnswer(Dialog.GetActiveDialogForPlayer(player), 1, n, info)
         --print("It is added to dialog correctly")
         n = n + 1
      end
    end
    --print("Ready to action")
    Dialog.Action(player)
  end
}

CustomAbility.Hero.is_loaded = 1