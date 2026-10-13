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
                showNearestEvent(this, widgetData)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    // Keys must match HomeWidgetService in lib/services/home_widget_service.dart.
    private fun showNearestEvent(views: RemoteViews, widgetData: SharedPreferences) {
        val title = widgetData.getString("nearest_event_title", null) ?: return
        val targetMillis =
            widgetData.getString("nearest_event_target_millis", null)?.toLongOrNull() ?: return
        val emoji = widgetData.getString("nearest_event_emoji", null) ?: DEFAULT_EMOJI

        val targetDate = Instant.ofEpochMilli(targetMillis).atZone(ZoneId.systemDefault()).toLocalDate()
        // Calendar days, matching CountdownCalculator.remainingDays in the app.
        val days = ChronoUnit.DAYS.between(LocalDate.now(), targetDate)

        views.setTextViewText(R.id.widget_title, "$emoji $title")
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
        val color = widgetData.getString("nearest_event_color", null)?.toLongOrNull()
        if (color != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            views.setColorStateList(
                R.id.widget_root,
                "setBackgroundTintList",
                ColorStateList.valueOf(color.toInt()),
            )
        }
    }

    private companion object {
        const val DEFAULT_EMOJI = "📅"
        val DATE_FORMAT: DateTimeFormatter = DateTimeFormatter.ofPattern("d MMMM", Locale.ENGLISH)
    }
}
