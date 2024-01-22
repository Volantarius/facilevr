include( "contextmenu.lua" )

local function CreateInteractionMenu()
	CreateContextMenu()
end

--hook.Add( "OnGamemodeLoaded", "CreateInteractionMenu", CreateInteractionMenu )
hook.Add( "InitPostEntity", "CreateInteractionMenu", CreateInteractionMenu )
concommand.Add( "fa_interactionmenu_reload", CreateInteractionMenu )

local function InteractionKeyboardFocusOn( pnl )

	if ( IsValid( g_ContextMenu ) && IsValid( pnl ) && pnl:HasParent( g_ContextMenu ) ) then
		g_ContextMenu:StartKeyFocus( pnl )
	end

end
hook.Add( "OnTextEntryGetFocus", "InteractionKeyboardFocusOn", InteractionKeyboardFocusOn )

local function InteractionKeyboardFocusOff( pnl )

	if ( IsValid( g_ContextMenu ) && IsValid( pnl ) && pnl:HasParent( g_ContextMenu ) ) then
		g_ContextMenu:EndKeyFocus( pnl )
	end

end
hook.Add( "OnTextEntryLoseFocus", "InteractionKeyboardFocusOff", InteractionKeyboardFocusOff )