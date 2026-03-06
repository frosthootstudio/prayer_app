package studio.frosthoot.prayer_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

class PrayerWidgetMediumProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.prayer_widget_medium)

            // Read saved data from Flutter
            val prayerName   = widgetData.getString("next_prayer_name", "—") ?: "—"
            val prayerTime   = widgetData.getString("next_prayer_time", "—") ?: "—"
            val prayerMillis = widgetData.getLong("next_prayer_millis", 0L)
            val isAllPassed  = widgetData.getBoolean("all_prayers_passed", false)
            val language     = widgetData.getString("language", "id") ?: "id"
            val listJson     = widgetData.getString("prayer_list", "[]") ?: "[]"

            // Next prayer section
            views.setTextViewText(R.id.text_prayer_name, prayerName)
            views.setTextViewText(R.id.text_prayer_time, prayerTime)

            val countdown = PrayerWidgetSmallProvider.buildCountdown(prayerMillis, isAllPassed, language)
            views.setTextViewText(R.id.text_countdown, countdown)

            val nextLabel = if (language == "en") "Next Prayer" else "Shalat Berikutnya"
            views.setTextViewText(R.id.text_next_label, nextLabel)

            // Upcoming prayers list
            val upcomingRowIds = listOf(
                Triple(R.id.row_upcoming_1, R.id.text_upcoming_name_1, R.id.text_upcoming_time_1),
                Triple(R.id.row_upcoming_2, R.id.text_upcoming_name_2, R.id.text_upcoming_time_2),
                Triple(R.id.row_upcoming_3, R.id.text_upcoming_name_3, R.id.text_upcoming_time_3),
            )

            try {
                val prayerList = JSONArray(listJson)
                upcomingRowIds.forEachIndexed { i, (rowId, nameId, timeId) ->
                    if (i < prayerList.length()) {
                        val item = prayerList.getJSONObject(i)
                        views.setViewVisibility(rowId, View.VISIBLE)
                        views.setTextViewText(nameId, item.getString("name"))
                        views.setTextViewText(timeId, item.getString("time"))
                    } else {
                        views.setViewVisibility(rowId, View.GONE)
                    }
                }
            } catch (_: Exception) {
                upcomingRowIds.forEach { (rowId, _, _) ->
                    views.setViewVisibility(rowId, View.GONE)
                }
            }

            // Tap to open app
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context, 1, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.text_prayer_name, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
