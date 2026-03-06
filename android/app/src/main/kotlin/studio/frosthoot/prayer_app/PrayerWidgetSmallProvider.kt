package studio.frosthoot.prayer_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PrayerWidgetSmallProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.prayer_widget_small)

            // Read saved data from Flutter
            val prayerName    = widgetData.getString("next_prayer_name", "—") ?: "—"
            val prayerTime    = widgetData.getString("next_prayer_time", "—") ?: "—"
            val prayerMillis  = widgetData.getLong("next_prayer_millis", 0L)
            val isAllPassed   = widgetData.getBoolean("all_prayers_passed", false)
            val language      = widgetData.getString("language", "id") ?: "id"

            views.setTextViewText(R.id.text_prayer_name, prayerName)
            views.setTextViewText(R.id.text_prayer_time, prayerTime)

            // Compute live countdown from stored millis
            val countdown = buildCountdown(prayerMillis, isAllPassed, language)
            views.setTextViewText(R.id.text_countdown, countdown)

            // Update "next prayer" label based on language
            val nextLabel = if (language == "en") "Next Prayer" else "Shalat Berikutnya"
            views.setTextViewText(R.id.text_next_label, nextLabel)

            // Tap to open app
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.text_prayer_name, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    companion object {
        fun buildCountdown(millis: Long, allPassed: Boolean, language: String): String {
            if (allPassed || millis == 0L) {
                return if (language == "en") "All prayers done" else "Semua shalat selesai"
            }
            val diff = millis - System.currentTimeMillis()
            if (diff <= 0) return if (language == "en") "Now" else "Sekarang"
            val hours   = diff / 3_600_000L
            val minutes = (diff % 3_600_000L) / 60_000L
            return if (hours > 0) {
                if (language == "en") "${hours}h ${minutes}m left" else "${hours}j ${minutes}m lagi"
            } else {
                if (language == "en") "${minutes}m left" else "${minutes}m lagi"
            }
        }
    }
}
