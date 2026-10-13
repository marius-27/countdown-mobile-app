package com.example.countdown_mobile_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.content.res.ColorStateList
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONException
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit
import java.util.Locale

/** Home screen widget showing the nearest upcoming countdown. */
class CountdownWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.countdown_widget).apply {
                // Tapping the widget opens the app.
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
                showNearestEvent(context, this, widgetData)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    // The key and fields must match HomeWidgetService in
    // lib/services/home_widget_service.dart.
    private fun showNearestEvent(
        context: Context,
        views: RemoteViews,
        widgetData: SharedPreferences,
    ) {
        // Events are saved nearest first. Skipping the ones that completed
        // while the app was closed moves the widget on to the next event.
        val now = System.currentTimeMillis()
        val event = upcomingEvents(widgetData).firstOrNull { it.targetMillis > now }
        if (event == null) {
            showEmptyState(context, views)
            return
        }
        val emoji = event.emoji ?: DEFAULT_EMOJI

        val targetDate = Instant.ofEpochMilli(event.targetMillis).atZone(ZoneId.systemDefault()).toLocalDate()
        // Calendar days, matching CountdownCalculator.remainingDays in the app.
        val days = ChronoUnit.DAYS.between(LocalDate.now(), targetDate)

        views.setTextViewText(R.id.widget_title, "$emoji ${event.title}")
        views.setViewVisibility(R.id.widget_days, View.VISIBLE)
        if (days <= 0) {
            views.setTextViewText(R.id.widget_days, "TODAY")
            views.setViewVisibility(R.id.widget_days_label, View.GONE)
        } else {
            views.setTextViewText(R.id.widget_days, days.toString())
            views.setTextViewText(R.id.widget_days_label, if (days == 1L) "DAY" else "DAYS")
            views.setViewVisibility(R.id.widget_days_label, View.VISIBLE)
        }
        views.setTextViewText(R.id.widget_date, targetDate.format(DATE_FORMAT))
        views.setViewVisibility(R.id.widget_date, View.VISIBLE)

        // Tinting keeps the rounded background shape; it needs Android 12+.
        val color = event.color
        if (color != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            views.setColorStateList(
                R.id.widget_root,
                "setBackgroundTintList",
                ColorStateList.valueOf(color.toInt()),
            )
        }
    }

    private fun upcomingEvents(widgetData: SharedPreferences): List<WidgetEvent> {
        val json = widgetData.getString("upcoming_events", null) ?: return emptyList()
        return try {
            val array = JSONArray(json)
            (0 until array.length()).map { index ->
                val item = array.getJSONObject(index)
                WidgetEvent(
                    title = item.getString("title"),
                    emoji = item.optString("emoji").takeUnless { item.isNull("emoji") },
                    targetMillis = item.getLong("targetMillis"),
                    color = if (item.isNull("color")) null else item.getLong("color"),
                )
            }
        } catch (e: JSONException) {
            emptyList()
        }
    }

    private data class WidgetEvent(
        val title: String,
        val emoji: String?,
        val targetMillis: Long,
        val color: Long?,
    )

    private fun showEmptyState(context: Context, views: RemoteViews) {
        views.setTextViewText(R.id.widget_title, context.getString(R.string.countdown_widget_empty))
        views.setViewVisibility(R.id.widget_days, View.GONE)
        views.setViewVisibility(R.id.widget_days_label, View.GONE)
        views.setTextViewText(R.id.widget_date, context.getString(R.string.countdown_widget_empty_hint))
        views.setViewVisibility(R.id.widget_date, View.VISIBLE)
    }

    private companion object {
        const val DEFAULT_EMOJI = "📅"
        val DATE_FORMAT: DateTimeFormatter = DateTimeFormatter.ofPattern("d MMMM", Locale.ENGLISH)
    }
}
