using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Math;

class GoalIndicator extends DataFieldDrawable {

  hidden var mStartDegree;
  hidden var mTotalDegree;
  hidden var mRadius;

  function initialize(params) {
    DataFieldDrawable.initialize(params);
    mStartDegree = params[:startDegree];
    mTotalDegree = params[:totalDegree];
    mRadius = app.gWidth / 2.0 * params[:scaling];
  }

  function draw(dc) {
    DataFieldDrawable.draw(dc);
    update(dc);
  }

  function update(dc) {
    if (dc has :clearClip) {
      dc.clearClip();
    }
    if(dc has :setAntiAlias) {
      dc.setAntiAlias(true);
    }
    dc.setPenWidth(app.gStrokeWidth);
    var mLastInfo = DataFieldInfo.getInfoForField(mFieldId);
    if (mLastInfo.progress > 1.0) {
      mLastInfo.progress = 1.0;
    }

    if (app.gDrawRemainingIndicator) {
      dc.setColor(Graphics.COLOR_DK_GRAY, Color.BACKGROUND);
      drawRemainingArc(dc, mLastInfo.progress, mLastInfo.fieldType == FieldType.BATTERY);
    }

    dc.setColor(themeColor(mFieldId), Color.BACKGROUND);
    drawProgressArc(dc, mLastInfo.progress, mLastInfo.fieldType == FieldType.BATTERY);

    if(dc has :setAntiAlias) {
      dc.setAntiAlias(false);
    }
  }

  function partialUpdate(dc) {
    drawPartialUpdate(dc, method(:update));
  }

  hidden function drawProgressArc(dc, fillLevel, reverse) {
    if (fillLevel > 0.0) {
      var startDegree = reverse ? mStartDegree - mTotalDegree + getFillDegree(fillLevel) : mStartDegree;
      var endDegree = reverse ? mStartDegree - mTotalDegree : mStartDegree - getFillDegree(fillLevel);

      dc.drawArc(
        app.gWidth / 2.0, // x center of ring
        app.gHeight / 2.0, // y center of ring
        mRadius,
        Graphics.ARC_CLOCKWISE,
        startDegree,
        endDegree
      );
      if (fillLevel < 1.0) {
        drawEndpoint(dc, reverse ? startDegree : endDegree);
      }
    }
  }

  hidden function drawRemainingArc(dc, fillLevel, reverse) {
    if (fillLevel < 1.0) {
      var startDegree = reverse ? mStartDegree : mStartDegree - getFillDegree(fillLevel);
      var endDegree =  mStartDegree - mTotalDegree;
      if (reverse) {
        endDegree += getFillDegree(fillLevel);
      }

      dc.drawArc(
        gWidth / 2.0, // x center of ring
        gHeight / 2.0, // y center of ring
        mRadius,
        Graphics.ARC_CLOCKWISE,
        startDegree,
        endDegree
      );
    }
  }

  hidden function drawEndpoint(dc, degree) {
    degree = Math.toRadians(degree);
    var x = app.gWidth / 2.0 + mRadius * Math.cos(degree);
    var y = app.gHeight - (app.gHeight / 2.0 + mRadius * Math.sin(degree));
    dc.fillCircle(x, y, app.gStrokeWidth + app.gStrokeWidth * 0.75);

    dc.setColor(Graphics.COLOR_WHITE, Color.BACKGROUND);
    dc.fillCircle(x, y, app.gStrokeWidth + app.gStrokeWidth * 0.25);
  }

  hidden function getFillDegree(fillLevel) {
    return mTotalDegree * fillLevel;
  }
}