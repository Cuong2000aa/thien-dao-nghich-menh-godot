extends NpcScript

#
const QUEST_ID : int = ProgressCommons.Quest.TULIMSHAR_OLD_FRIENDSHIP
var sealedLettersID : int = DB.GetCellHash("Sealed Letters")
var heavyEnvelopeID : int = DB.GetCellHash("Heavy Envelope")

#
func OnStart():
	var questState : int = GetQuest(QUEST_ID)
	if questState != ProgressCommons.TULIMSHAR_OLD_FRIENDSHIP.STARTED:
		return

	ExchangeItems([], [sealedLettersID, heavyEnvelopeID], OnEnvelopesExchanged)

func OnEnvelopesExchanged(result : ActorInventory.ExchangeResult):
	match result:
		ActorInventory.ExchangeResult.OK:
			SetQuest(QUEST_ID, ProgressCommons.TULIMSHAR_OLD_FRIENDSHIP.ENVELOPES_FOUND)
			Mes("Hai phong bì cũ kẹp giữa sách bụi.")
			Mes("Một niêm cẩn thận, một nặng bất ngờ.")
		ActorInventory.ExchangeResult.NO_SPACE:
			Mes("Thấy phong bì rồi, nhưng túi đầy không mang được.")
